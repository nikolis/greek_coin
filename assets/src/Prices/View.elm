module Prices.View exposing (..)

import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (attribute, class, scope, disabled, style, href)
import Api.Data exposing (..)
import Api.Calls exposing (..)
import Dict exposing (Dict)
import Paginate exposing (..)

toTableRow:  Dict String AssetMetaInfo -> AssetPair-> Html msg
toTableRow metaInfo assetPair =
   case Dict.get assetPair.info.alternate_name metaInfo of
       Nothing ->
           case Dict.get assetPair.name metaInfo of
               Nothing ->
                 tr []
                 [ td[][text assetPair.info.alternate_name]
                 , td[][text assetPair.info.base]
                 ]

               Just assetMetaInf ->
                  tr []
                  [ td[][text assetPair.info.alternate_name]
                  , td[][text assetPair.info.base]
                  , td[][text assetMetaInf.o.today]
                  , td[][text assetMetaInf.a.price]
                  , td[][text assetMetaInf.b.price]
                  ]

       Just assetMetaInfo ->
         tr []
         [ td[][text assetPair.info.alternate_name]
         , td[][text assetPair.info.base]
         , td[][text assetMetaInfo.o.today]
         , td[][text assetMetaInfo.a.price]
         , td[][text assetMetaInfo.b.price]
         , td[][text assetMetaInfo.c.price]
         , td[][text (String.fromInt assetMetaInfo.t.today)]
         ]



viewPaginated : PaginatedList AssetPair  -> Dict String AssetMetaInfo  -> (Int -> msg) ->  msg->  msg->  msg ->  msg -> Html msg
viewPaginated assetPairs  metaInfo goTo prev next first last=
    let
        
        displayInfoView =
            div []
                [ text <|
                    String.join " "
                        [ "page"
                        , String.fromInt <| Paginate.currentPage assetPairs
                        , "of"
                        , String.fromInt <| Paginate.totalPages assetPairs
                        ]
                , div[] [ table [class "table"]
                  ( [
                       thead [class "thead-light"]
                       [ 
                          th [scope "col"] [ text "Name" ]
                       ,  th [scope "col"] [ text "Base" ]
                       ,  th [scope "col"] [ text "Openning value"]
                       ,  th [scope "col"] [ text "Ask price"]
                       ,  th [scope "col"] [ text "Bid Price"]
                       ,  th [scope "col"] [ text "Last closed Trade price"]
                       ,  th [scope "col"] [ text "Number of Trades last 24h"]
                       ]
                   ] ++  
                   (List.map (toTableRow metaInfo) (page assetPairs)))
                     
                ]
                ]

        
        prevButtons =
            [ li[class "page-item"] [ button [class "page-link", onClick first, disabled <| Paginate.isFirst assetPairs ] [ text "<<" ]]
            , li[class "page-item"] [button [class "page-link", onClick prev, disabled <| Paginate.isFirst assetPairs ] [ text "<" ]]
            ]

        nextButtons =
            [ li[class "page-item"] [button [class "page-link", onClick next, disabled <| Paginate.isLast assetPairs ] [ text ">" ]]
            , li[class "page-item"] [button [class "page-link", onClick last, disabled <| Paginate.isLast assetPairs ] [ text ">>" ]]
            ]

        pagerButtonView index isActive =
           li [class "page-item"]
           [ button
                 [class "page-link"
                   , style "font-weight"
                    (if isActive then
                        "bold"
                     else
                        "normal"
                    )
                , (onClick <| goTo index)
                ]
                [ text <| String.fromInt index ]
            ]
          

        pagerOptions =
            { innerWindow = 2
            , outerWindow = 0
            , pageNumberView = pagerButtonView
            , gapView = text "..."
            }
    in
    nav[] [
       displayInfoView
       , ul[class "pagination pagination-lg"]
          (
       prevButtons
       ++ Paginate.elidedPager pagerOptions assetPairs
       ++  nextButtons
       )
      ]

assetsToNamesCsv : List AssetPair -> String
assetsToNamesCsv assetList = 
    let
       
       cnct = 
          \original pair -> 
            let
               new_info_2= {alternate_name = original.info.alternate_name ++ ","++pair.info.alternate_name} 
            in  
            { info = new_info_2}
       new_info = {alternate_name = "ZECUSD"}
       result = 
           List.foldr (cnct) {info = new_info} assetList
    in
    result.info.alternate_name
 

mapperOfAssets : Dict String AssetPairInfo -> List AssetPair
mapperOfAssets dict =
    let 
       dict_trans =  Dict.map (\k a -> {name = k, info = a}) dict
    in
    Dict.values dict_trans



