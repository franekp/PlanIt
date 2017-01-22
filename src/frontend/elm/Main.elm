import Html as H exposing (Html)
import Html
import Html.Attributes as Att
import Html.Events as Ev
import Http
import Json.Decode as Json
import Task

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart, onDragEnd, onClick)
-- onClick = mouseDown and mouseUp without a mouseMove in between

import SortableList

(:=) = Json.field


main = Html.program {
    init = SortableList.init,
    update = SortableList.update,
    subscriptions = SortableList.subscriptions,
    view = SortableList.view,
  }

{-
main = Html.program {
    init = init [
      ["item1", "item2", "item3"],
      ["item4", "item5"],
      ["item7". "item8"],
    ],
    update = update,
    subscriptions = subscriptions,
    view = view,
  }
-}

type alias Model = {
  board : List CardList,
  dragging : Maybe {card_id : CardId, delta: Draggable.Delta},
  hovering : Maybe {card_id : Maybe CardId, card_list_id : CardListId},
  drag : Draggable.State,
}

type alias CardId = Int
type alias CardListId = Int

type alias CardList = {
  ident : CardListId,
  cards : List Card,
}

type alias Card = {
  ident : CardId,
  text : String,
}

type Msg =
  | DragMsg Draggable.Msg
  | DragStart String
  | DragBy Draggable.Delta
  | DragEnd
  | MouseEnterCardList CardListId
  | MouseLeaveCardList CardListId
  | MouseEnterCard CardId
  | MouseLeaveCard CardId

init : List (List String) -> (Model, Cmd Msg)
init input = ({
    board = List.indexedMap (\i -> List.indexedMap Card >> CardList i) input,
    dragging = Nothing,
    hovering = Nothing,
    drag = Draggable.init,
  }, Cmd.none)

dragConfig : Draggable.Config Msg
dragConfig =
  Draggable.customConfig [
    onDragStart DragStart,
    onDragBy DragBy,
    onDragEnd DragEnd,
  ]

subscriptions : Model -> Sub Msg
subscriptions {drag} =
  Draggable.subscriptions DragMsg drag

update : Msg -> Model -> (Model, Cmd Msg)
update msg ({board, dragging, hovering, drag} as model) =
  case msg of
    DragMsg dragMsg ->
      Draggable.update dragConfig dragMsg model

    DragStart ugly_dragging_string_index -> {
        model |
        dragging = ugly_dragging_string_index
          |> String.toInt |> Result.toMaybe
          |> Maybe.map (\card_id -> {card_id = card_id, delta = (0.0, 0.0)})
      } ! []

    DragBy dragged_delta ->
      let apply_delta (a, b) (c, d) = (a + c, b + d) in
      case dragging of
        Just ({card_id, delta} as dragging) -> {
            model |
            dragging = Just {dragging | delta = apply_delta delta dragged_delta}
          } ! []

        Nothing -> model ! []  -- should not be possible

    DragEnd -> stop_dragging model ! []

    -- TODO TODO TODO
    MouseEnterCardList card_list_id -> model ! []
    MouseLeaveCardList card_list_id -> model ! []
    MouseEnterCard card_id -> model ! []
    MouseLeaveCard card_id -> model ! []


stop_dragging : Model -> Model
stop_dragging ({board, dragging, hovering, drag} as model) =
  case dragging of
    Nothing -> model  -- should not be possible

    Just dragging ->
      case hovering of
        -- dropped outside allowed places, card returns to it's previous place
        Nothing -> {model | dragging = Nothing}

        Just hovering ->
          let dragging_card =
            board |> List.concatMap (.cards)
            |> List.filter (.ident >> ((==) dragging.card_id)) |> List.head
          in case dragging_card of
            Nothing -> {model | dragging = Nothing}  -- should not be possible

            Just dragging_card ->
              let update_card_list ({ident} as card_list) =
                let cards =
                  card_list.cards
                  |> List.filter (.ident >> ((/=) dragging.card_id))
                in if ident /= hovering.card_list_id then
                  {ident = ident, cards = cards}
                else
                  case hovering.card_id of
                    Nothing ->
                      {ident = ident, cards = cards ++ [dragging_card]}

                    Just hovering_card_id ->
                      let insert_helper input output =
                        case input of
                          [] -> output

                          h::t ->
                            if h.ident == hovering_card_id then
                              insert_helper t (h::dragging_card::output)
                            else
                              insert_helper t (h::output)
                      in let insert_into input =
                        insert_helper input [] |> List.reverse
                      in {ident = ident, cards = insert_into cards}
              in {
                model |
                dragging = Nothing,
                board = List.map update_card_list model.board,
              }
