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


(:=) = Json.field

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
  dragging : Maybe {
    card : Card, delta: Draggable.Delta, card_list_id : CardListId,
  },
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
  --| EditStart CardListId CardId
  --| EditInProgress String
  --| EditEnd

card_to_string : (Card, CardListId) -> String
card_to_string ({ident, text}, card_list_id) =
  toString card_list_id ++ "\n" ++ toString ident ++ "\n" ++ text

card_from_string : String -> Maybe (Card, CardListId)
card_from_string str =
  case String.split "\n" str of
    [card_list_id, ident, text] ->
      (Maybe.map2 (\card_list_id -> \ident ->
        ({ident = ident, text = text}, card_list_id)
      ))
      (card_list_id |> String.toInt |> Result.toMaybe)
      (ident |> String.toInt |> Result.toMaybe)
    _ -> Nothing

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

    DragStart string_representing_card -> {
        model |
        dragging = card_from_string string_representing_card
          |> Maybe.map (\(card, card_list_id) -> {
            card = card, delta = (0.0, 0.0), card_list_id = card_list_id,
          })
      } ! []

    DragBy dragged_delta ->
      let apply_delta (a, b) (c, d) = (a + c, b + d) in
      case dragging of
        Just ({card, delta} as dragging) -> {
            model |
            dragging = Just {dragging | delta = apply_delta delta dragged_delta}
          } ! []

        Nothing -> model ! []  -- should not be possible

    DragEnd -> stop_dragging model ! []

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
          if hovering.card_list_id == card_list_id then
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
              if card_id == hovering_card_id then
                {model | hovering = Just {hovering | card_id = Nothing}} ! []
              else
                model ! []

    MouseUp -> {
        model | google_chrome_mouse_up_hack = {card = True, card_list = True}
      } ! []

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
            |> List.filter (.ident >> ((==) dragging.card.ident)) |> List.head
          in case dragging_card of
            Nothing -> {model | dragging = Nothing}  -- should not be possible

            Just dragging_card ->
              let update_card_list ({ident} as card_list) =
                let cards =
                  card_list.cards
                  |> List.filter (.ident >> ((/=) dragging.card.ident))
                in if ident /= hovering.card_list_id then
                  {ident = ident, cards = cards}
                else
                  case hovering.card_id of
                    Nothing ->
                      {ident = ident, cards = cards ++ [dragging_card]}

                    Just hovering_card_id ->
                      if hovering_card_id == dragging.card.ident then card_list
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
  let
    dragging_card_css delta =
      let
        (x, y) = delta
        need_to_offset_up = case hovering of
          Nothing -> False
          Just hovering -> case hovering.card_id of
            Nothing -> False
            Just _ -> case dragging of
              Nothing -> False  -- should not be possible
              Just dragging ->
                dragging.card_list_id == hovering.card_list_id && y < 0
      in {
        inline = [
          "transform" => (""
            ++ "translateX(" ++ toString (round x) ++ "px) "
            ++ "translateY(" ++ toString (round y) ++ "px) "
            ++ (if need_to_offset_up then "translateY(-100%) " else "")
            ++ "scale(1.15, 1.15) "
          ),
          "pointer-events" => "none",
          "z-index" => "10",
        ],
        class_list = ["card", "dragging"],
        is_hovering = False,
      }
    normal_card_css = {
      inline = [
        "cursor" => "default",
        "z-index" => "1",
      ],
      class_list = ["card"],
      is_hovering = False,
    }
    hovering_card_css = {
      inline = ["z-index" => "1"],
      class_list = ["card", "hovering"],
      is_hovering = True,
    }
    ghost_card_css = {
      inline = ["z-index" => "1"],
      class_list = ["card", "ghost"],
      is_hovering = False,
    }
  in let get_card_css card =
    case dragging of
      Nothing -> normal_card_css

      Just dragging ->
        if dragging.card.ident == card.ident then
          dragging_card_css dragging.delta
        else
          case hovering of
            Nothing -> normal_card_css

            Just hovering ->
              case hovering.card_id of
                Nothing -> normal_card_css

                Just hovering_card_id ->
                  if hovering_card_id == card.ident then
                    hovering_card_css
                  else
                    normal_card_css
  in let view_card card_list_id card =
    let css = get_card_css card in (
      if css.is_hovering then
        [H.div [
          Att.style ghost_card_css.inline,
          Att.classList <|
            List.map (\c -> (c, True)) ghost_card_css.class_list,
          Ev.onMouseEnter <| MouseEnterCard card.ident,
          Ev.onMouseLeave <| MouseLeaveCard card.ident,
          Ev.onMouseUp <| MouseUp,
        ] [H.text "------"]]
      else []
    ) ++ [H.div [
      Att.style css.inline,
      Att.classList <| List.map (\c -> (c, True)) css.class_list,
      Draggable.mouseTrigger (card_to_string (card, card_list_id)) DragMsg,
      Ev.onMouseEnter <| MouseEnterCard card.ident,
      Ev.onMouseLeave <| MouseLeaveCard card.ident,
      Ev.onMouseUp <| MouseUp,
    ] <| [H.text card.text]]
  in let view_card_list card_list = H.div [
    Att.class "card_list",
    Ev.onMouseEnter <| MouseEnterCardList card_list.ident,
    Ev.onMouseLeave <| MouseLeaveCardList card_list.ident,
  ] <| List.concat <| List.map (view_card card_list.ident) card_list.cards
  in H.div [
    Att.class "board",
    Att.style <| case dragging of
        Nothing -> []
        Just _ -> ["cursor" => "move"]
  ] <| List.map view_card_list board
