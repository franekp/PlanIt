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


(:=) = Decode.field


main = Html.program {
    init = Board.init Board.test_data,
    update = Board.update,
    subscriptions = Board.subscriptions,
    view = Board.view,
  }
{-
type BoardState =
  | BoardStillLoading BoardLoader.Model
  | BoardAlrealdyLoaded Board.Model

type alias Model = {
  board : BoardState,

}
-}
