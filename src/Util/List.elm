module Util.List exposing (..)

{-| Takes an integer n and a list and groups the elements of the list into
sublists of size n.

    group 2 [1, 2, 3, 4, 5, 6, 7] == [ [1, 2], [3, 4], [5, 6], [7]]

-}


group : Int -> List a -> List (List a)
group n list =
    let
        grouping =
            (List.take n list)
    in
        if (List.length list) < n then
            [ grouping ]
        else
            (grouping :: (group n (List.drop n list)))
