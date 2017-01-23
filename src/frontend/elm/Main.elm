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

{-
main = Html.program {
    init = SortableList.init,
    update = SortableList.update,
    subscriptions = SortableList.subscriptions,
    view = SortableList.view,
  }
-}

main = Html.program {
    init = init [
      [1 => "item1", 2 => "item2", 3 => "item3"],
      [4 => "item4", 5 => "item5"],
      [7 => "item7", 8 => "item8"],
    ],
    update = update,
    subscriptions = subscriptions,
    view = view,
  }


type alias Model = {
  board : List CardList,
  dragging : Maybe {card_id : CardId, delta: Draggable.Delta},
  hovering : Maybe {card_id : Maybe CardId, card_list_id : CardListId},
  drag : Draggable.State,
  google_chrome_mouse_up_hack : {card : Bool, card_list : Bool},
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
  | MouseUp

init : List (List (Int, String)) -> (Model, Cmd Msg)
init input = ({
    board = List.indexedMap (\i -> \li -> CardList i <|
        List.map (\(id, text) -> {ident = id, text = text}) li
      ) input,
    dragging = Nothing,
    hovering = Nothing,
    drag = Draggable.init,
    google_chrome_mouse_up_hack = {card = False, card_list = False},
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

    DragEnd -> stop_dragging (Debug.log "DragEnd" model) ! []

    MouseEnterCardList card_list_id -> {
        model |
        hovering = Just {card_id = Nothing, card_list_id = card_list_id}
      } ! []

    MouseLeaveCardList card_list_id ->
      let google_chrome_mouse_up_hack = model.google_chrome_mouse_up_hack in
      if model.google_chrome_mouse_up_hack.card_list then {
          model | google_chrome_mouse_up_hack = {
            google_chrome_mouse_up_hack | card_list = False
        }} ! []
      else case hovering of
        Nothing -> model ! []

        Just hovering ->
          if hovering.card_list_id == Debug.log "MouseLeaveCardList" card_list_id then
            {model | hovering = Nothing} ! []
          else
            model ! []

    MouseEnterCard card_id ->
      case hovering of
        Nothing -> model ! []  -- TODO some error message

        Just hovering -> {
            model |
            hovering = Just {hovering | card_id = Just card_id}
          } ! []

    MouseLeaveCard card_id ->
      let google_chrome_mouse_up_hack = model.google_chrome_mouse_up_hack in
      if model.google_chrome_mouse_up_hack.card then {
          model | google_chrome_mouse_up_hack = {
            google_chrome_mouse_up_hack | card = False
        }} ! []
      else case hovering of
        Nothing -> model ! []

        Just hovering ->
          case hovering.card_id of
            Nothing -> model ! []

            Just hovering_card_id ->
              if card_id == Debug.log "MouseLeaveCard" hovering_card_id then
                {model | hovering = Just {hovering | card_id = Nothing}} ! []
              else
                model ! []

    MouseUp -> {
        model | google_chrome_mouse_up_hack = {card = True, card_list = True}
      } ! Debug.log "MouseUp" []

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
                      if hovering_card_id == dragging.card_id then card_list
                      else let insert_helper input output =
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

(=>) = \a -> \b -> (a, b)

view : Model -> Html Msg
view ({board, dragging, hovering, drag} as model) =
  let get_card_style card =
    case dragging of
      Nothing -> []

      Just dragging ->
        if dragging.card_id == card.ident then
          let (x, y) = dragging.delta in [
            "transform" => (
              "translateX(" ++ toString (round x) ++ "px) "
              ++ "translateY(" ++ toString (round y) ++ "px) "
              ++ "scale(1.15, 1.15) "
            ),
            "pointer-events" => "none",
            "z-index" => "10",
          ]
        else
          case hovering of
            Nothing -> []

            Just hovering ->
              case hovering.card_id of
                Nothing -> []

                Just hovering_card_id ->
                  if hovering_card_id == card.ident then [
                    "border-top-color" => "red",
                    "border-top-width" => "4px",
                    "cursor" => "move",
                  ] else []
  in let view_card card = H.div [
      Att.style <| [
          "border-width" => "2px",
          "border-style" => "solid",
          "border-color" => "gray",
          "border-top-color" => "gray",
          "border-top-width" => "2px",
          "margin" => "5px",
          "padding" => "8px",
          "background-color" => "white",
          "width" => "5em",
          "cursor" => "default",
      ] ++ get_card_style card,
      Draggable.mouseTrigger (toString card.ident) DragMsg,
      Ev.onMouseEnter <| MouseEnterCard card.ident,
      Ev.onMouseLeave <| MouseLeaveCard card.ident,
      Ev.onMouseUp <| MouseUp,
    ] <| [H.text card.text]
  in let view_card_list card_list = H.div [
    Att.style [
      "border-width" => "3",
      "border-style" => "solid",
      "border-color" => "black",
      "display" => "inline-block",
      "margin" => "12px",
      "vertical-align" => "top",
    ],
    Ev.onMouseEnter <| MouseEnterCardList card_list.ident,
    Ev.onMouseLeave <| MouseLeaveCardList card_list.ident,
  ] <| List.map view_card card_list.cards
  in H.div [
    Att.style <| [
        "bottom" => "0px",
        "top" => "0px",
        "position" => "absolute",
        "left" => "0px",
        "right" => "0px",
      ] ++ case dragging of
        Nothing -> []
        Just _ -> ["cursor" => "move"]
  ] <| List.map view_card_list board
