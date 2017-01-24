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

{-
main = Html.program {
    init = Board.init Board.test_data,
    update = Board.update,
    subscriptions = Board.subscriptions,
    view = Board.view,
  }
-}

main = Html.program {
    init = init,
    update = update,
    subscriptions = subscriptions,
    view = view,
  }

type BoardState =
  | BoardDataLoading DataLoader.Model
  | BoardDataReady Board.Model

type alias Model = {
  board : BoardState,
  error : Maybe String,
}

type Msg =
  | DataLoaderMsg DataLoader.Msg
  | BoardMsg Board.Msg

init : (Model, Cmd Msg)
init =
  let (loader_model, loader_cmd) = DataLoader.init in {
    board = BoardDataLoading loader_model,
    error = Nothing,
  } ! [Cmd.map DataLoaderMsg loader_cmd]

subscriptions {board} =
  case board of
    BoardDataLoading _ -> Sub.none
    BoardDataReady board -> Board.subscriptions board |> Sub.map BoardMsg

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({board} as model) = case board of
  BoardDataLoading loader_model -> case msg of
    BoardMsg _ -> model ! []  -- should not be possible

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

  BoardDataReady board -> case msg of
    DataLoaderMsg _ -> model ! []  -- should not be possible

    BoardMsg msg ->
      let (board_model, board_cmd) = Board.update msg board in {
        model | board = BoardDataReady board_model
      } ! [Cmd.map BoardMsg board_cmd]

view : Model -> Html Msg
view {board, error} =
  H.div [] [
    case error of
      Nothing -> H.text "no errors"
      Just err -> H.h1 [] [H.text <| "error: " ++ err]
    ,
    case board of
      BoardDataLoading li ->
        let progress = (toFloat <| List.length li) / 7.0 * 100 |> toString in
        H.h1 [] [H.text progress]

      BoardDataReady board ->
        Html.map BoardMsg <| Board.view board
    ,
  ]
