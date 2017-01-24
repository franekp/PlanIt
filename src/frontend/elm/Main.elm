import Html as H exposing (Html)
import Html
import Html.Attributes as Att
import Html.Events as Ev
import Html.Lazy
import Dom
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task

import Board
import DataLoader


(:=) = Decode.field


main = Html.program {
    init = init,
    update = update,
    subscriptions = subscriptions,
    view = view,
  }

type BoardState =
  | BoardDataLoading DataLoader.Model
  | BoardDataReady Board.Model

type Model =
  | Loading {error : Maybe String}
  | NotLoggedIn
  | LoggedIn ModelLoggedIn

type alias ModelLoggedIn = {
  board : BoardState,
  error : Maybe String,
  user : User,
}

type Msg =
  | DataLoaderMsg DataLoader.Msg
  | BoardMsg Board.Msg
  | AuthenticatedUserResponse User
  | AnonymousUserResponse
  | Error String

type alias User = {
  username : String,
  full_name : String,
  profile_photo : String,
}

init : (Model, Cmd Msg)
init =
  let
    user_response_decoder : Decode.Decoder Msg
    user_response_decoder =
      ("authenticated" := Decode.bool)
      |> Decode.andThen (\authenticated ->
        if not authenticated then
          Decode.succeed AnonymousUserResponse
        else (
            Decode.map3 User
            ("username" := Decode.string)
            ("full_name" := Decode.string)
            ("profile_photo" := Decode.string)
          ) |> Decode.map AuthenticatedUserResponse
      )
  in Loading {error = Nothing} ! [
    Http.get "/api/current_user.json" user_response_decoder
    |> Http.send (\result ->
      case result of
        Ok value -> value
        Err error -> Error <| toString error
    )
  ]

subscriptions model = case model of
  LoggedIn {board} ->
    case board of
      BoardDataLoading _ -> Sub.none
      BoardDataReady board -> Board.subscriptions board |> Sub.map BoardMsg
  _ -> Sub.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case model of
    LoggedIn model ->
      let (new_model, cmd) = update_logged_in msg model in
      LoggedIn new_model ! [cmd]

    NotLoggedIn -> case msg of
      Error err -> Loading {error = Just err} ! []
      _ -> model ! []

    Loading {error} ->
      case msg of
        AnonymousUserResponse -> NotLoggedIn ! []

        Error err -> case error of
          Nothing -> Loading {error = Just err} ! []
          Just error -> Loading {
            error = Just <| error ++ "\n\n|NEXT ERROR|\n\n" ++ err
          } ! []

        AuthenticatedUserResponse user ->
          let (loader_model, loader_cmd) = DataLoader.init in LoggedIn {
            board = BoardDataLoading loader_model, user = user, error = Nothing
          } ! [Cmd.map DataLoaderMsg loader_cmd]

        _ -> model ! []

update_logged_in : Msg -> ModelLoggedIn -> (ModelLoggedIn, Cmd Msg)
update_logged_in msg ({board} as model) =
  case msg of
    Error err -> {model | error = Just err} ! []
    _ -> case board of
      BoardDataLoading loader_model -> case msg of
        DataLoaderMsg DataLoader.Done ->
          let (board_model, board_cmd) = Board.init loader_model in
          {model | board = BoardDataReady board_model} ! [
            Cmd.map BoardMsg board_cmd
          ]

        DataLoaderMsg (DataLoader.Error err) ->
          {model | error = Just err} ! []

        DataLoaderMsg a ->
          let (new_loader_model, loader_cmd) = DataLoader.update a loader_model
          in {model | board = BoardDataLoading new_loader_model} ! [
            Cmd.map DataLoaderMsg loader_cmd
          ]

        _ -> model ! []  -- should not be possible

      BoardDataReady board -> case msg of
        BoardMsg msg ->
          let (board_model, board_cmd) = Board.update msg board in {
            model | board = BoardDataReady board_model
          } ! [Cmd.map BoardMsg board_cmd]

        _ -> model ! []  -- should not be possible

view : Model -> Html Msg
view model = H.div [] [view_error model, view_navbar model, view_main model]

view_error : Model -> Html Msg
view_error model =
  let error_element error = case error of
    Nothing -> H.text ""
    Just error -> H.div [Att.class "error"] [H.text error]
  in case model of
    NotLoggedIn -> error_element Nothing

    Loading {error} -> error_element error

    LoggedIn {error} -> error_element error

view_navbar : Model -> Html Msg
view_navbar model =
  let
    not_logged_in_navbar = H.div [Att.class "navbar"] [
        H.span [Att.class "brand"] [H.text "PlanIt"],
        H.a [Att.class "login_link", Att.href "/accounts/login/"] [H.text "Log in"],
        H.a [
          Att.class "register_link", Att.href "/accounts/signup/"
        ] [H.text "Register"],
      ]
    logged_in_navbar user =
      let display_name = if user.full_name /= ""
        then user.full_name
        else user.username
      in H.div [Att.class "navbar"] [
        H.span [Att.class "brand"] [H.text "PlanIt"],
        H.a [
          Att.class "profile_link", Att.href "/manage/",
        ] [H.img [Att.src user.profile_photo] [], H.text display_name],
        H.a [Att.class "logout_link", Att.href "/accounts/logout/"] [H.text "Log out"],
      ]
  in case model of
    LoggedIn {user} -> logged_in_navbar user

    NotLoggedIn -> not_logged_in_navbar

    Loading _ -> not_logged_in_navbar

view_main : Model -> Html Msg
view_main model = case model of
  LoggedIn model -> view_logged_in model

  NotLoggedIn ->
    H.div [Att.class "main"] [
      H.h3 [Att.class "please_log_in"] [
        H.text
          "You are not logged in, log in or register to see this page."
      ]
    ]

  Loading _ -> H.div [Att.class "main"] [
      H.h3 [Att.class "loading"] [
        H.text "Loading..."
      ]
    ]

view_logged_in : ModelLoggedIn -> Html Msg
view_logged_in {board, error} = case board of
  BoardDataLoading li ->
    let progress = (toFloat <| List.length li) / 7.0 * 100.0 |> toString in
    H.div [Att.class "main"] [
        H.h3 [Att.class "loading"] [
          H.text <| "Loading... (" ++ progress ++ ")"
        ]
      ]

  BoardDataReady board ->
    H.div [Att.class "main"] [
      Html.map BoardMsg <| Board.view board
    ]
