import Html as H exposing (Html)
import Html
import Html.Attributes as Att
import Html.Events as Ev
import Http
import Json.Decode as Json
import Task

import Draggable

import SortableList


(:=) = Json.field


main = Html.program
    { init = init
    , update = update
    , subscriptions = subscriptions
    , view = view
    }

-- MODEL

type alias Model = {
    a : SortableList.Model,
    b : SortableList.Model
  }

-- type Msg is imported from SortableList
type Action
  = SortableListA_a SortableList.Msg
  | SortableListA_b SortableList.Msg

init : (Model, Cmd Action)
init = ({
    a = let (x, _) = SortableList.init in x,
    b = let (x, _) = SortableList.init in x
  }, Cmd.none)

-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    SortableListA_a act ->
      let (newmod, cmd) = SortableList.update act model.a in
      ({model | a = newmod}, Cmd.map SortableListA_a cmd)
    SortableListA_b act ->
      let (newmod, cmd) = SortableList.update act model.b in
      ({model | b = newmod}, Cmd.map SortableListA_b cmd)

-- VIEW

view : Model -> Html Action
view {a, b} =
  H.div [Att.class "week_container"] [
    H.div [Att.class "day_container"] [
      Html.map SortableListA_a <| SortableList.view a
    ],
    H.div [Att.class "day_container"] [
      Html.map SortableListA_b <| SortableList.view b
    ]
  ]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions {a, b} =
  Sub.batch [
    Sub.map SortableListA_a <| Draggable.subscriptions SortableList.DragMsg a.drag,
    Sub.map SortableListA_b <| Draggable.subscriptions SortableList.DragMsg b.drag
  ]


-- JSON PARSING

-- not yet
