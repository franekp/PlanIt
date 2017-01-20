import Html as H exposing (Html)
import Html
import Html.Attributes as Att
import Html.Events as Ev
import Http
import Json.Decode as Json
import Task

import SortableList

(:=) = Json.field


--main = SortableList.main

main = Html.program
    { init = SortableList.init
    , update = SortableList.update
    , subscriptions = SortableList.subscriptions
    , view = SortableList.view
    }

{-

main = Html.program {
    init = init,
    view = view,
    update = update,
    subscriptions = subscriptions
  }

-- MODEL

type Tab = LoginT | RegisterT | WeekViewT
type alias Model = {
    active_tab : Tab
  }
type Action
  = ShowTab Tab
init : (Model, Cmd Action)
init = ({active_tab = LoginT}, Cmd.none)

-- UPDATE

update : Action -> Model -> (Model, Cmd Action)
update action model =
  case action of
    ShowTab t -> ({model | active_tab = t}, Cmd.none)

-- VIEW

view : Model -> Html Action
view model =
  case model.active_tab of
    LoginT -> H.div [] [H.text "Login"]
    RegisterT -> H.div [] [H.text "Register"]
    WeekViewT -> H.div [] [H.text "WeekView"]

-- SUBSCRIPTIONS

subscriptions : Model -> Sub Action
subscriptions model =
  Sub.none

-- JSON PARSING

-- not yet

-}
