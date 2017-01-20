module ArrayX exposing (..)


-- copied from:
-- https://github.com/circuithub/elm-array-extra/blob/1.1.2/src/Array/Extra.elm

import Array exposing (..)
import List
import Maybe
import Debug


{-| Unsafe version of get, don_t use this unless you know what Youre doing!
-}
getUnsafe : Int -> Array a -> a
getUnsafe n xs =
  case get n xs of
    Just x -> x
    Nothing -> Debug.crash ("Index " ++ toString n ++ " of Array with length " ++ toString (length xs) ++ " is not reachable.")

{-| Split an array into two arrays, the first ending at and the second starting at the given index
-}
splitAt : Int -> Array a -> (Array a, Array a)
splitAt index xs =
  -- TODO: refactor (written this way to help avoid Array bugs)
  let len = length xs
  in case (index > 0, index < len) of
    (True,  True ) -> (slice 0 index xs, slice index len xs)
    (True,  False) -> (xs,               empty)
    (False, True ) -> (empty,            xs)
    (False, False) -> (empty,            empty)

{-| Remove the element at the given index
-}
removeAt : Int -> Array a -> Array a
removeAt index xs =
  -- TODO: refactor (written this way to help avoid Array bugs)
  let (xs0, xs1) = splitAt index xs
      len1       = length xs1
  in  if len1 == 0
      then xs0
      else (slice 1 len1 xs1) |> append xs0
