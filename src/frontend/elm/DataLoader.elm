module DataLoader exposing (..)

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


(:=) = Decode.field


type alias Model = List (String, List (Int, String))

type Msg =
  | Done
  | CurrentWeekArrived (List String)
  | DataArrived (String, List (Int, String))
  | Error String

init : (Model, Cmd Msg)
init =
  let decode_current_week = ("days" := Decode.list Decode.string) in
  [] ! [
    Http.get "/api/current_week.json" decode_current_week
    |> Http.send (\result ->
      case result of
        Ok days -> CurrentWeekArrived days
        Err error -> Error <| toString error
    )
  ]

fetch_day : String -> Cmd Msg
fetch_day day =
  let decode_day =
    (Decode.map2 (\day -> \cards -> (day, cards)) <|
      (Decode.succeed day)) <|
      ((Decode.list <|
        Decode.map3 (\ident -> \text -> \pos -> (pos, ident, text))
        ("id" := Decode.int)
        ("text" := Decode.string)
        ("position_in_list" := Decode.int)
      ) |> Decode.map (List.sort >> (List.map (\(pos, id, text) -> (id, text)))))
  in Http.get ("/api/day/" ++ day ++ "/cards.json") decode_day
  |> Http.send (\result ->
    case result of
      Ok data -> DataArrived data
      Err error -> Error <| toString error
  )

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = case msg of
  Done -> model ! []

  CurrentWeekArrived days -> model ! (List.map fetch_day days)

  DataArrived data ->
    let new_model = data::model in
    if List.length new_model >= 7 then
      List.sort new_model ! [
        Task.perform identity (Task.succeed Done)
      ]
    else
      new_model ! []

  Error _ -> model ! []
