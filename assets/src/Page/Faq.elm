module Page.Faq exposing  (Model, Msg, init, subscriptions, toSession, update, view)

import Session exposing (Session)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Page.Home.Naview as Nav
import Svg exposing (svg, rect)
import Svg.Attributes
import Page.Home.Packages exposing (viewGettingStarted)
import Dict exposing (Dict)
import Page.Home.Packages as PackagesP

type alias Model =
    {
        session : Session
    ,   content : Dict Int Bool
    ,   packagesModel : PackagesP.Model
    }

init : Session ->(Model, Cmd Msg) 
init session =
    let
        (modelPackages, cmdsPackages) = PackagesP.init session

        md = 
            {
                session = session
            ,   content = Dict.fromList 
                [ (1, False)
                , (2, False)
                , (3, False)
                , (4, False)
                ]
            ,   packagesModel = modelPackages
            }
    in
    (md, Cmd.none)

type Msg = 
    Toggle Int
    | PackageMsg PackagesP.Msg 


subscriptions : Model -> Sub Msg
subscriptions model=
  Sub.none

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
       let
           _ = Debug.log "asffads" "asfdfasd"
       in 
    case msg of
        Toggle integ ->
            let
                _ = Debug.log "asdfafsd" "asdafsd"
                dictNew = Dict.update integ (\item -> 
                    case item of 
                      Just sthing -> 
                          Just (not sthing)
                      Nothing ->
                        Nothing
                    )  model.content
                _ = Debug.log "inteher" integ
            in
            ({model | content = dictNew}, Cmd.none)

        PackageMsg servMsg ->
           let
               (serM, comSer) = PackagesP.update  servMsg model.packagesModel
           in
           ({model |packagesModel  = serM}, Cmd.map (\serCom -> (PackageMsg serCom)) comSer)



view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Faq"
    , content = 
      div[]
      [
         div[style "padding-right" "100px", style "margin-left" "-15px",style "background-image" "url(\"images/faq.png.svg\")", style "background-repeat" "no-repeat", style "background-size" "cover"]
         [
             div[class "col", style "margin-right" "10vw"]
             [
              Nav.naview model.session 2
             ]
         , div[class "row", style "width" "100%"]
           [
               div[class "col", style "margin-left" "10vw"]
               [
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "FAQ"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Cryptocurrency at a glance"]
               , br[][]
               , svg[style "margin-top" "3vh"]
                 [
                   rect
                   [ Svg.Attributes.fill "rgba(255,158,46,1)"
                   , Svg.Attributes.rx "7"
                   , Svg.Attributes.ry "7"
                   , Svg.Attributes.x "0"
                   , Svg.Attributes.y "0"
                   , Svg.Attributes.width "125"
                   , Svg.Attributes.height "14"
                   ][]
                 ] 
               ]
               
               , div[class "col-6"][]
           ]
         ]
        , div[class "container-fluid", style "margin-top" "10vh", style "margin-bottom" "10vh" ]
          [
              div[class "row no-gutters", style "margin-left" "5vw", style "margin-right" "5vw"]
              [
                  div[class "col"]
                  [ 
                      div[class "row no-gutters"]
                      [
                        div[class "col col-sm-12 col-xs-12 col-lg", style "margin-bottom" "50px"]
                        [
                          div[class "row no-gutters align-items-center", style "background-color" "rgb(239, 239, 239)", style "margin-right" "10px"]
                          [
                            div[class "col-3", style "height" "100%"][img[style "width" "5vw",src "/images/fac_bitcoin.svg", style "background-color" "rgb(0, 99, 166)"][]]
                          , div[class "col-8"][span[style "font-size" "2rem" , style "font-weight" "bold", style "margin-top" "50px", style "margin-bottom" "auto", style "color" "rgba(68,68,68,1)", style "font-weight" "bolder"][text "Time to Buy Cryptocurrencies"]]
                          , div[class "col-1"][ img[style "width" "3vw", src "/images/fac_minus.svg",onClick (Toggle 1 ),style "cursor" "pointer"][]]
                          ]
                        , div[class "row", style "margin-top" "35px"]
                          [
                           div[class "col"]
                            [
                               (case Dict.get 1  model.content of 
                                  Just smt->
                                      if smt then  
                                        iframe[src "https://www.youtube.com/embed/6Gu2QMTAkEU", style "width" "100%", style "height" "25rem"][] 
                                      else
                                        div[][]
                                  Nothing ->
                                      div[][]
                                  )
{--                               (case Dict.get  1 model.content of 
                                  Just smt->
                                      if smt then  
                                          span[][text "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."]                                                                                    else
                                          div[][]
                                  Nothing ->
                                      div[][]
                                )
--}
                            ]
                          ]
                        ]
                     , div[class "col col-sm-12 col-xs-12 col-lg", style "margin-bottom" "50px"]
                        [
                          div[class "row no-gutters align-items-center", style "background-color" "rgb(239, 239, 239)", style "margin-right" "10px"]
                          [
                            div[class "col-3", style "height" "100%"][img[style "width" "5vw",src "/images/fac_bitcoin.svg", style "background-color" "rgb(0, 99, 166)"][]]
                          , div[class "col-8"][span[style "font-size" "2rem" , style "font-weight" "bold", style "margin-top" "50px", style "margin-bottom" "auto", style "color" "rgba(68,68,68,1)", style "font-weight" "bolder"][text "Time to Buy Cryptocurrencies"]]
                          , div[class "col-1"][ img[style "width" "3vw", src "/images/fac_minus.svg",onClick (Toggle 2 ),style "cursor" "pointer"][]]
                          ]
                        , div[class "row", style "margin-top" "35px"]
                          [
                           div[class "col"]
                            [
                               (case Dict.get 2  model.content of 
                                  Just smt->
                                      if smt then  
                                        iframe[src "https://www.youtube.com/embed/6Gu2QMTAkEU", style "width" "100%", style "height" "25rem"][] 
                                      else
                                        div[][]
                                  Nothing ->
                                      div[][]
                                  )
{--                               (case Dict.get  1 model.content of 
                                  Just smt->
                                      if smt then  
                                          span[][text "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."]                                                                                    else
                                          div[][]
                                  Nothing ->
                                      div[][]
                                )
--}
                            ]
                          ]

                        ]
 
                      ]
                  , div[class "row no-gutters", style "margin-bottom" "50px"]
                      [
                        div[class "col col-sm-12 col-xs-12 col-lg", style "margin-bottom" "50px"]
                        [
                          div[class "row no-gutters align-items-center", style "background-color" "rgb(239, 239, 239)", style "margin-right" "10px"]
                          [
                            div[class "col-3", style "height" "100%"][img[style "width" "5vw",src "/images/fac_bitcoin.svg", style "background-color" "rgb(0, 99, 166)"][]]
                          , div[class "col-8"][span[style "font-size" "2rem" , style "font-weight" "bold", style "margin-top" "50px", style "margin-bottom" "auto", style "color" "rgba(68,68,68,1)", style "font-weight" "bolder"][text "Time to Buy Cryptocurrencies"]]
                          , div[class "col-1"][ img[style "width" "3vw", src "/images/fac_minus.svg",onClick (Toggle 3 ),style "cursor" "pointer"][]]
                          ]
                        , div[class "row", style "margin-top" "35px"]
                          [
                           div[class "col"]
                            [
                               (case Dict.get 3  model.content of 
                                  Just smt->
                                      if smt then  
                                        iframe[src "https://www.youtube.com/embed/6Gu2QMTAkEU", style "width" "100%", style "height" "25rem"][] 
                                      else
                                        div[][]
                                  Nothing ->
                                      div[][]
                                  )
                            ]
                          ]


                        ]
                     , div[class "col col-sm-12 col-xs-12 col-lg", style "margin-bottom" "50px"]
                        [
                          div[class "row no-gutters align-items-center", style "background-color" "rgb(239, 239, 239)", style "margin-right" "10px"]
                          [
                            div[class "col-3", style "height" "100%"][img[style "width" "5vw",src "/images/fac_bitcoin.svg", style "background-color" "rgb(0, 99, 166)"][]]
                          , div[class "col-8"][span[style "font-size" "2rem" , style "font-weight" "bold", style "margin-top" "50px", style "margin-bottom" "auto", style "color" "rgba(68,68,68,1)", style "font-weight" "bolder"][text "Time to Buy Cryptocurrencies"]]
                          , div[class "col-1"][ img[style "width" "3vw", src "/images/fac_minus.svg",onClick (Toggle 4 ),style "cursor" "pointer"][]]
                          ]
                        , div[class "row", style "margin-top" "35px"]
                          [
                           div[class "col"]
                            [
                               (case Dict.get 4  model.content of 
                                  Just smt->
                                      if smt then  
                                        iframe[src "https://www.youtube.com/embed/6Gu2QMTAkEU", style "width" "100%", style "height" "25rem"][] 
                                      else
                                        div[][]
                                  Nothing ->
                                      div[][]
                                  )
{--                               (case Dict.get  1 model.content of 
                                  Just smt->
                                      if smt then  
                                          span[][text "It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."]                                                                                    else
                                          div[][]
                                  Nothing ->
                                      div[][]
                                )
--}
                            ]
                          ]


                        ]
                      ]
 
 
                  ]
              ] 
           , div[class "row", style "margin-top" "10vh"]
               (List.map(\arg -> Html.map(\packMsg -> PackageMsg packMsg) arg) (PackagesP.viewGettingStarted))

          ]
      ] 
    }


toSession : Model -> Session
toSession model = 
    model.session
