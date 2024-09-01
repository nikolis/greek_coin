module Page.Home.Services exposing (Model, Msg, init, update, view)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes as Attrs
import Svg exposing (svg, path, polygon, g, rect) 
import Svg.Attributes exposing (..)
import Html.Events exposing (..)
type alias Model = 
    {
        session: Session
    ,   textOf : String
    }

init: Session -> (Model, Cmd Msg)
init session = 
    let
        md = 
          { session = session 
          , textOf = 
                """
                Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.
                """
          }
    in
    (md, Cmd.none)

type Msg =
    GotSession Session
    | ClickedCard

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        GotSession sess->
            ({model | session = sess}, Cmd.none)
        ClickedCard -> 
            ({model | textOf = 
                """
                Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC.
                """}, Cmd.none)


view : Model -> Html Msg
view model = 
   div[Attrs.style "text-align" "center", Attrs.style "width" "100%", class "container-lg"]
   [
       h1[Attrs.style "color" "rgba(0,99,166,1)", Attrs.style "font-weight" "bold", Attrs.style "text-shadow" "2px 0 rgba(0,99,166,1)"][text "Our Services"]
   ,   span[Attrs.style "font-size" "1.25rem",Attrs.style "color" "rgba(68,68,68,1)"][text "We are offering Cryptocurrencies with the largest capitalization in the market."]
   ,   br[][]
   ,   span[Attrs.style "font-size" "1.25rem",Attrs.style "color" "rgba(68,68,68,1)"][text "Available instantly."]
   ,   viewCards model
   ]

viewCards : Model -> Html Msg
viewCards model =
  div[Attrs.style "background-color" "rgba(242,242,242,1)", Attrs.style "box-shadow" "5px 5px 15px 5px rgba(242, 242, 242,1) , 10px 10px 25px 10px rgba(242,242,242, 0.8)", Attrs.style "border-radius" "30px"]
  [
    div[Attrs.class "card-deck ", Attrs.style "margin-bottom" "5vh", Attrs.style "margin-top" "5vh"]
    [
       div[Attrs.class "card card-service "]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top" ]
              [
                  div[][ buySvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh"]
               [
                   span[][text "Buy Cryptocurrencies"]
                ]
           ,  p[class "card-text"][ text "You can buy the most popular cryptocurrencies in the market. Deposit with Sepa Bank Transfer and exchange Euros for cryptos."]
               
           ]
        ]

    ,  div[Attrs.class "card card-service"]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top"]
              [
                  div[ ][ sellSvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh" ]
               [
                   text "Sell Cryptocurrencies"
                ]
           ,  p[class "card-text"][ text "You can sell the most popular cryptocurrencies in the market. Deposit cryptocurrencies, exchange for Euros and get money to your Bank account."]

           ]
        ]
    ,  div[Attrs.class "card card-service"]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top"]
              [
                  div[][ exchangeSvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh" ]
               [
                   text "Cryptocurrency Exchange"
                ]
           ,  p[class "card-text"][ text "You can even exchange Cryptocurrencies for other cryptocurrencies"]

           ]
        ]          
    ]
  , div[Attrs.class "card-deck"]
    [
       div[Attrs.class "card card-service"]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top"]
              [
                  div[][ learnSvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh" ]
               [
                   text "Learn With Us"
                ]
           ,  p[class "card-text"][ text "You can learn more about cryptocurrencies from our knowledge base (avaliable soon)"]

           ]
        ]

    ,  div[Attrs.class "card card-service"]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top"]
              [
                  div[][ mineSvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh" ]
               [
                   text "Earn Cryptocurrencies"
                ]
           ,  p[class "card-text"][ text "You can Earn cryptocurrencies through our referal program or earn rewards by simply choosing us to safely store your cryptocurrencies(avaliable soon) "]

           ]
        ]
    ,  div[Attrs.class "card card-service", onClick ClickedCard]
        [
           div[Attrs.class "card-body"]
           [
              div[class "card-img-top"]
              [
                  div[][ walletSvg]
              ]

           ,  h5[Attrs.class "card-title", Attrs.style "margin-top" "1.5vh" ]
               [
                   text "Secure Wallet"
                ]
           ,  p[class "card-text"][ text "You can safely store your cryptocurrencies to our platform"]

           ]
        ]          
    ]
  ]


buySvg : Html Msg
buySvg = 
    svg [ viewBox "0 -40 480 479" ] [ Svg.path [ d "m112 311.707031c61.855469 0 112-50.144531 112-112s-50.144531-112-112-112-112 50.144531-112 112c.0664062 61.828125 50.171875 111.933594 112 112zm0-208c53.019531 0 96 42.980469 96 96s-42.980469 96-96 96-96-42.980469-96-96c.058594-52.996093 43.003906-95.941406 96-96zm0 0" ] [], Svg.path [ d "m256 199.707031c0 61.855469 50.144531 112 112 112s112-50.144531 112-112-50.144531-112-112-112c-61.828125.066407-111.933594 50.171875-112 112zm208 0c0 53.019531-42.980469 96-96 96s-96-42.980469-96-96 42.980469-96 96-96c52.996094.058594 95.941406 43.003907 96 96zm0 0" ] [], Svg.path [ d "m120 64.507812h32v-16h-10.398438c60.222657-43.734374 142.070313-42.535156 200.984376 2.953126l9.78125-12.664063c-66.074219-50.957031-158.164063-51.074219-224.367188-.28125v-14.007813h-16v32c0 4.417969 3.582031 8 8 8zm0 0" ] [], Svg.path [ d "m362.175781 69.195312 11.648438-10.976562c-3.65625-3.871094-7.527344-7.632812-11.503907-11.199219l-10.640624 12c3.632812 3.207031 7.160156 6.640625 10.496093 10.175781zm0 0" ] [], Svg.path [ d "m114.175781 341.195312c3.65625 3.871094 7.527344 7.632813 11.503907 11.199219l10.640624-11.960937c-3.632812-3.199219-7.160156-6.65625-10.496093-10.191406zm0 0" ] [], Svg.path [ d "m145.40625 347.957031-9.78125 12.664063c66.074219 50.957031 158.171875 51.074218 224.375.277344v14.007812h16v-32c0-4.417969-3.582031-8-8-8h-32v16h10.398438c-60.222657 43.734375-142.070313 42.535156-200.984376-2.949219zm0 0" ] [], Svg.path [ d "m80 255.707031h16v-8h16v8h16v-8.40625c11.644531-1.621093 21.019531-10.382812 23.417969-21.894531 2.398437-11.511719-2.691407-23.289062-12.722657-29.425781 4.871094-6.703125 6.492188-15.230469 4.421876-23.253907-2.066407-8.023437-7.613282-14.699218-15.117188-18.210937v-10.808594h-16v8h-16v-8h-16v8h-16v16h8v64h-8v16h16zm8-88h28c6.628906 0 12 5.371094 12 12 0 6.628907-5.371094 12-12 12h-28zm36 64h-36v-24h36c6.628906 0 12 5.371094 12 12 0 6.628907-5.371094 12-12 12zm0 0" ] [], Svg.path [ d "m168 191.707031h16v16h-16zm0 0" ] [], Svg.path [ d "m40 191.707031h16v16h-16zm0 0" ] [], Svg.path [ d "m304 191.707031h16v16h-16zm0 0" ] [], Svg.path [ d "m416 191.707031h16v16h-16zm0 0" ] [], Svg.path [ d "m360 143.707031v8.265625c-12.488281 1.179688-22.4375 10.957032-23.84375 23.421875-1.40625 12.464844 6.117188 24.210938 18.027344 28.144531l22.570312 7.519532c4.9375 1.632812 7.957032 6.613281 7.128906 11.75-.832031 5.136718-5.273437 8.90625-10.476562 8.898437h-10.8125c-5.851562-.007812-10.589844-4.75-10.59375-10.601562v-5.398438h-16v5.398438c.042969 13.644531 10.421875 25.03125 24 26.335937v8.265625h16v-8.265625c12.488281-1.179687 22.4375-10.953125 23.84375-23.421875 1.40625-12.464843-6.117188-24.210937-18.027344-28.144531l-22.570312-7.519531c-4.9375-1.632813-7.957032-6.613281-7.128906-11.75.832031-5.136719 5.273437-8.90625 10.476562-8.898438h10.8125c5.851562.007813 10.589844 4.75 10.59375 10.601563v5.398437h16v-5.398437c-.042969-13.644532-10.421875-25.03125-24-26.335938v-8.265625zm0 0" ] [] ]

sellSvg : Html Msg
sellSvg =
    svg [ viewBox "0 0 64 64" ] [ g [ id "outline" ] [ Svg.path [ d "M29,20h2V18h2v2h2V18a2.987,2.987,0,0,0,2.22-5A2.987,2.987,0,0,0,35,8V6H33V8H31V6H29V8H27v2h2v6H27v2h2Zm7-9a1,1,0,0,1-1,1H31V10h4A1,1,0,0,1,36,11Zm-5,3h4a1,1,0,0,1,0,2H31Z" ] [], Svg.path [ d "M17,57v1H47V57a2,2,0,0,1,2-2h1V47H49a2,2,0,0,1-2-2V44H17v1a2,2,0,0,1-2,2H14v8h1A2,2,0,0,1,17,57Zm10-6a5,5,0,1,1,5,5A5.006,5.006,0,0,1,27,51Zm18.126-5A4.016,4.016,0,0,0,48,48.874v4.252A4.016,4.016,0,0,0,45.126,56H36.89a6.979,6.979,0,0,0,0-10ZM16,48.874A4.016,4.016,0,0,0,18.874,46H27.11a6.979,6.979,0,0,0,0,10H18.874A4.016,4.016,0,0,0,16,53.126Z" ] [], Svg.path [ d "M47.449,40H10V62H54V40H49.792C51.109,37.721,53,33.791,53,30a20.745,20.745,0,0,0-3.7-11.6l3.533.588.33-1.972-6-1a1,1,0,0,0-1.151.821l-1,6,1.972.33.619-3.711A18.759,18.759,0,0,1,51,30C51,33.289,49.215,37.23,47.449,40ZM52,60H12V42H52Z" ] [], Svg.path [ d "M7.485,31.857l5,3a1,1,0,0,0,1.372-.342l3-5-1.714-1.03L13.1,31.9Q13,30.954,13,30a18.445,18.445,0,0,1,8.15-15.271,11,11,0,1,0-.121-2.3A20.49,20.49,0,0,0,11,30c0,.563.039,1.124.084,1.684L8.515,30.143ZM32,4a9,9,0,1,1-9,9A9.011,9.011,0,0,1,32,4Z" ] [] ] ]

exchangeSvg : Html Msg
exchangeSvg =
    svg [ version "1.1", id "Capa_1", x "0px", y "0px", viewBox "0 0 480.001 480.001", style "enable-background:new 0 0 480.001 480.001;" ] [ g [] [ g [] [ Svg.path [ d "M416,224.001c3.156-0.01,6.01-1.875,7.288-4.76l0.056-0.128l31.936-71.856c0.466-1.023,0.711-2.132,0.72-3.256v-136 c0.053-4.365-3.442-7.947-7.807-8C448.129,0,448.064,0,448,0.001H304c-3.047-0.017-5.838,1.699-7.2,4.424l-32,64h0.08 c-0.574,1.105-0.875,2.331-0.88,3.576v64h-48v-128c0.053-4.365-3.442-7.947-7.807-8C208.129,0,208.064,0,208,0.001H64 c-3.032-0.001-5.805,1.712-7.16,4.424l-32,64h0.08c-0.588,1.102-0.903,2.328-0.92,3.576v144c0,4.418,3.582,8,8,8h64v32H64 c-3.032-0.001-5.805,1.712-7.16,4.424l-32,64h0.08c-0.588,1.102-0.903,2.328-0.92,3.576v144c0,4.418,3.582,8,8,8h144 c3.156-0.01,6.01-1.875,7.288-4.76l0.056-0.128l29.856-67.112H264v64c0,4.418,3.582,8,8,8h144c3.156-0.01,6.01-1.875,7.288-4.76 l0.056-0.128l31.936-71.856c0.466-1.023,0.711-2.132,0.72-3.256v-136c0.053-4.365-3.442-7.947-7.807-8 c-0.064-0.001-0.129-0.001-0.193,0h-96v-32H416z M440,142.305l-16,36V73.889l16-32V142.305z M308.944,16.001h126.112l-24,48 H284.944L308.944,16.001z M184,136.001V73.889l16-32v94.112H184z M195.688,152.001L184,178.305v-26.304H195.688z M68.944,16.001 h126.112l-24,48H44.944L68.944,16.001z M40,208.001v-128h128v56H96v16h72v56H40z M68.944,272.001H96v48H44.944L68.944,272.001z M168,464.001H40v-128h56v72h16v-72h56V464.001z M171.056,320.001H112v-48h83.056L171.056,320.001z M184,434.305v-26.304h11.688 L184,434.305z M200,392.001h-16v-62.112l16-32V392.001z M264.8,324.425h0.08c-0.574,1.105-0.875,2.331-0.88,3.576v64h-48v-128 c0.053-4.365-3.442-7.947-7.807-8c-0.064-0.001-0.129-0.001-0.193,0h-96v-32h64c3.156-0.01,6.01-1.875,7.288-4.76l0.056-0.128 l29.856-67.112H264v64c0,4.418,3.582,8,8,8h64v32h-32c-3.047-0.017-5.838,1.699-7.2,4.424L264.8,324.425z M336,272.001v48h-51.056 l24-48H336z M408,464.001H280v-56h72v-16h-72v-56h128V464.001z M440,398.305l-16,36V329.889l16-32V398.305z M435.056,272.001 l-24,48H352v-48H435.056z M336,136.001v72h-56v-128h128v128h-56v-72H336z" ] [] ] ] ]

mineSvg : Html Msg
mineSvg =
  svg [ id "Layer_1", enableBackground "new 0 0 512.044 512.044", viewBox "0 0 512.044 512.044" ] [ Svg.path [ d "m447.715 387.717v-6.177c0-4.418-3.582-8-8-8s-8 3.582-8 8v4.471h-6.448v-4.471c0-4.418-3.582-8-8-8s-8 3.582-8 8v4.471h-6.965c-4.418 0-8 3.582-8 8s3.582 8 8 8h1.977v48.02h-1.977c-4.418 0-8 3.582-8 8s3.582 8 8 8h6.965v4.471c0 4.418 3.582 8 8 8s8-3.582 8-8v-4.471h6.448v4.471c0 4.418 3.582 8 8 8s8-3.582 8-8v-6.177c15.474-6.208 20.008-26.033 8.566-38.304 11.451-12.279 6.895-32.101-8.566-38.304zm-8.831 62.313h-18.605v-15.594h18.605c4.299 0 7.797 3.498 7.797 7.797s-3.498 7.797-7.797 7.797zm0-48.019c4.299 0 7.797 3.498 7.797 7.797s-3.498 7.797-7.797 7.797h-18.605v-15.594z" ] [], Svg.path [ d "m372.491 228.521c-63.816 0-118.94 43.072-134.903 103.84-20.008-8.87-42.13-10.049-62.126-4.373-4.25 1.207-6.718 5.63-5.512 9.881 1.207 4.25 5.629 6.718 9.88 5.512 19.729-5.6 41.293-2.958 59.218 7.715 4.786 2.85 10.96.047 11.962-5.436 10.713-58.604 61.803-101.139 121.48-101.139 71.054 0 127.754 60.12 123.249 131.395-15.048-20.249-39.14-33.396-66.249-33.396-45.491 0-82.5 37.01-82.5 82.5s37.009 82.5 82.5 82.5c55.637 0 95.375-54.219 78.721-107.193 20.876-88.052-46.247-171.806-135.72-171.806zm57 263c-36.668 0-66.5-29.832-66.5-66.5s29.832-66.5 66.5-66.5 66.5 29.832 66.5 66.5-29.831 66.5-66.5 66.5z" ] [], Svg.path [ d "m155.589 355.315c3.55-2.629 4.297-7.64 1.668-11.189-2.63-3.552-7.639-4.298-11.19-1.668-.484.358-.965.722-1.441 1.09-3.497 2.701-4.142 7.726-1.44 11.222 2.709 3.507 7.737 4.133 11.222 1.44.39-.303.784-.601 1.181-.895z" ] [], Svg.path [ d "m337.991 491.521h-137.5c-59.987 0-95.185-66.474-63.785-115.919 2.369-3.729 1.266-8.674-2.464-11.042-3.73-2.367-8.673-1.265-11.042 2.464-38.585 60.753 5.676 140.497 76.791 140.497h138c4.418 0 8-3.582 8-8s-3.581-8-8-8z" ] [], Svg.path [ d "m156.096 403.182c3.975 1.951 8.764.3 10.706-3.657 3.589-7.313 9.573-13.358 16.851-17.022 3.946-1.987 5.535-6.797 3.548-10.743-1.987-3.945-6.797-5.535-10.743-3.548-10.373 5.223-18.903 13.84-24.019 24.265-1.947 3.966-.31 8.759 3.657 10.705z" ] [], Svg.path [ d "m350.854 275.872c-1.491-4.159-6.07-6.323-10.231-4.83-.907.325-1.808.665-2.703 1.017-8.189 3.223-5.863 15.446 2.932 15.446 1.925 0 2.816-.557 5.172-1.402 4.159-1.491 6.322-6.073 4.83-10.231z" ] [], Svg.path [ d "m298.579 323.213c8.163 0 6.014-7.89 22.066-22.078 3.31-2.926 3.622-7.981.696-11.292s-7.981-3.622-11.292-.696c-7.189 6.354-13.349 13.731-18.306 21.924-3.247 5.365.681 12.142 6.836 12.142z" ] [], Svg.path [ d "m145.401 136.957c-3.155-3.092-8.221-3.039-11.313.116l-101.502 103.599c-.861.879-2.222.829-3.037.03l-12.913-12.652c-.845-.828-.859-2.189-.031-3.035l119.134-121.596 34.155 33.464c3.101 3.038 8.045 3.049 11.165.021 104.361 82.131 96.701 77.034 100.654 77.034 4.423 0 5.195-1.869 17.923-14.86 2.857-2.917 3.06-7.518.47-10.674l-77.262-94.147c2.984-3.204 2.829-8.146-.249-11.163l-52.328-51.27c-2.871-2.814-7.375-3.059-10.544-.563l-20.286-19.875c-9.455-9.263-24.637-9.149-33.94.347l-9.343 9.536c-9.261 9.452-9.106 24.677.347 33.939l20.286 19.875c-2.394 3.163-2.128 7.683.78 10.532l6.744 6.607-119.135 121.596c-7.002 7.147-6.885 18.659.263 25.661l12.913 12.652c7.181 7.037 18.656 6.892 25.664-.262l101.502-103.599c3.091-3.156 3.039-8.22-.117-11.313zm135.622 58.256-88.692-69.8 19.256-19.653 71.598 87.246zm-75.34-106.29-30.306 30.932c-14.276-13.986-34.465-33.766-40.899-40.07l30.306-30.933zm-98.101-56.458c9.428-9.623 10.59-11.891 14.976-11.938 4.432 0 3.869.511 25.915 22.109l-20.541 20.965-20.234-19.823c-3.151-3.087-3.203-8.163-.116-11.313z" ] [] ]


learnSvg : Html Msg
learnSvg = 
  svg [ viewBox "0 0 64 64" ] [ g [ id "Bitcoin" ] [ Svg.path [ d "M40,27a6.006,6.006,0,0,0-6-6V18a1,1,0,0,0-2,0v3H30.009L30,18a1,1,0,0,0-1-1h0a1,1,0,0,0-1,1l.009,3H23a1,1,0,0,0,0,2h3V41H23a1,1,0,0,0,0,2h5v3a1,1,0,0,0,2,0V43h2.018L32,45.994A1,1,0,0,0,32.994,47H33a1,1,0,0,0,1-.994L34.019,43A6,6,0,0,0,37.31,32,6,6,0,0,0,40,27ZM38,37a4,4,0,0,1-4,4H28V33h6A4,4,0,0,1,38,37Zm-4-6H28V23h6a4,4,0,0,1,0,8Z" ] [], Svg.path [ d "M61,33a1,1,0,0,0,0-2H50.949a18.838,18.838,0,0,0-.639-4H56a3,3,0,0,0,3-3V20.858a4,4,0,1,0-2,0V24a1,1,0,0,1-1,1H49.647A19.1,19.1,0,0,0,41,15.273V10a1,1,0,0,1,1-1h2.142a4,4,0,1,0,0-2H42a3,3,0,0,0-3,3v4.353a18.833,18.833,0,0,0-6-1.3V3a1,1,0,0,0-2,0V13.051a18.833,18.833,0,0,0-6,1.3V10a3,3,0,0,0-3-3H19.858a4,4,0,1,0,0,2H22a1,1,0,0,1,1,1v5.273A19.1,19.1,0,0,0,14.353,25H8a1,1,0,0,1-1-1V20.858a4,4,0,1,0-2,0V24a3,3,0,0,0,3,3h5.69a18.838,18.838,0,0,0-.639,4H3a1,1,0,0,0,0,2H13.051a18.838,18.838,0,0,0,.639,4H8a3,3,0,0,0-3,3v3.142a4,4,0,1,0,2,0V40a1,1,0,0,1,1-1h6.353A19.1,19.1,0,0,0,23,48.727V54a1,1,0,0,1-1,1H19.858a4,4,0,1,0,0,2H22a3,3,0,0,0,3-3V49.647a18.833,18.833,0,0,0,6,1.3V61a1,1,0,0,0,2,0V50.949a18.833,18.833,0,0,0,6-1.3V54a3,3,0,0,0,3,3h2.142a4,4,0,1,0,0-2H42a1,1,0,0,1-1-1V48.727A19.1,19.1,0,0,0,49.647,39H56a1,1,0,0,1,1,1v3.142a4,4,0,1,0,2,0V40a3,3,0,0,0-3-3H50.31a18.838,18.838,0,0,0,.639-4ZM56,17a2,2,0,1,1,2,2A2,2,0,0,1,56,17ZM48,6a2,2,0,1,1-2,2A2,2,0,0,1,48,6ZM16,10a2,2,0,1,1,2-2A2,2,0,0,1,16,10ZM4,17a2,2,0,1,1,2,2A2,2,0,0,1,4,17ZM8,47a2,2,0,1,1-2-2A2,2,0,0,1,8,47Zm8,11a2,2,0,1,1,2-2A2,2,0,0,1,16,58Zm32-4a2,2,0,1,1-2,2A2,2,0,0,1,48,54Zm12-7a2,2,0,1,1-2-2A2,2,0,0,1,60,47ZM32,49A17,17,0,1,1,49,32,17.019,17.019,0,0,1,32,49Z" ] [] ] ]

walletSvg : Html Msg
walletSvg =
   svg [ version "1.1", id "Capa_1", x "0px", y "0px", viewBox "0 0 480.16 480.16", style "enable-background:new 0 0 480.16 480.16;" ] [ g [] [ g [] [ Svg.path [ d "M384.08,128.16h-14.544c-26.01-40.463-79.898-52.179-120.36-26.168c-0.86,0.553-1.711,1.121-2.552,1.704 c8.66-47.823-23.088-93.612-70.911-102.272C127.889-7.237,82.1,24.512,73.44,72.335C69.831,92.265,73.208,112.83,83,130.56 c-16.054,5.537-26.851,20.619-26.92,37.6v272c0.026,22.08,17.92,39.974,40,40h288c22.08-0.026,39.974-17.92,40-40v-272 C424.053,146.079,406.16,128.186,384.08,128.16z M295.967,104.142c25.746-0.023,49.543,13.712,62.401,36.017 c6.344,10.938,9.694,23.355,9.712,36c0.011,8.178-1.388,16.297-4.136,24h-17.328c12.027-25.144,3.661-55.307-19.6-70.664 c-18.814-12.218-43.058-12.218-61.872,0c-23.261,15.357-31.627,45.52-19.6,70.664h-17.328c-2.748-7.703-4.147-15.822-4.136-24 C224.044,136.422,256.229,104.178,295.967,104.142z M329.625,197.607c-0.572,0.874-1.178,1.726-1.818,2.552h-63.456 c-5.309-6.88-8.215-15.31-8.272-24c-0.006-13.415,6.722-25.937,17.912-33.336c13.434-8.72,30.742-8.72,44.176,0 C336.46,154.788,341.59,179.315,329.625,197.607z M160.08,16.16c39.765,0,72,32.235,72,72c0,39.764-32.235,72-72,72 c-39.764,0-72-32.236-72-72C88.128,48.415,120.335,16.208,160.08,16.16z M72.08,168.16c0.047-11.865,8.758-21.916,20.496-23.648 c28.96,34.819,79.656,41.891,117.04,16.328c-0.968,5.051-1.482,10.178-1.536,15.32c0.026,8.122,1.187,16.2,3.448,24H96.08 c-13.255,0-24-10.745-24-24V168.16z M176.08,352.16c-4.418,0-8-3.582-8-8s3.582-8,8-8s8,3.582,8,8S180.498,352.16,176.08,352.16z M408.08,344.16h-136c-13.255,0-24-10.745-24-24s10.745-24,24-24h136V344.16z M408.08,280.16h-136c-22.091,0-40,17.909-40,40 c0,22.091,17.909,40,40,40h136v80c0,13.255-10.745,24-24,24h-160v-36l26.664-20h14.808c4.418,12.497,18.131,19.046,30.627,14.627 c12.497-4.418,19.046-18.131,14.627-30.627s-18.131-19.046-30.627-14.627c-6.835,2.416-12.211,7.793-14.627,14.627H248.08 c-1.731,0-3.415,0.561-4.8,1.6l-32,24c-2.014,1.511-3.2,3.882-3.2,6.4v40h-24v-97.472c12.497-4.418,19.046-18.131,14.627-30.627 s-18.131-19.046-30.627-14.627c-12.497,4.418-19.046,18.131-14.627,30.627c2.416,6.835,7.793,12.211,14.627,14.627v97.472h-24v-64 c0-2.122-0.844-4.156-2.344-5.656l-21.656-21.656v-38.16c12.497-4.418,19.046-18.131,14.627-30.627 c-4.418-12.497-18.131-19.046-30.627-14.627s-19.046,18.131-14.627,30.627c2.416,6.835,7.793,12.211,14.627,14.627v41.472 c0,2.122,0.844,4.156,2.344,5.656l21.656,21.656v60.688h-32c-13.255,0-24-10.745-24-24V207.952c6.883,5.294,15.316,8.179,24,8.208 h288c8.684-0.029,17.117-2.914,24-8.208V280.16z M280.08,400.16c0-4.418,3.582-8,8-8s8,3.582,8,8s-3.582,8-8,8 S280.08,404.578,280.08,400.16z M112.08,320.16c-4.418,0-8-3.582-8-8s3.582-8,8-8s8,3.582,8,8S116.498,320.16,112.08,320.16z M408.08,176.16c0,13.255-10.745,24-24,24h-3.448c5.397-18.444,4.437-38.168-2.728-56h6.176c13.255,0,24,10.745,24,24V176.16z" ] [] ] ], g [] [ g [] [ Svg.path [ d "M160.08,32.16c-30.928,0-56,25.072-56,56c0.035,30.913,25.087,55.965,56,56c30.928,0,56-25.072,56-56 C216.08,57.232,191.008,32.16,160.08,32.16z M160.08,128.16c-22.091,0-40-17.909-40-40c0.026-22.08,17.92-39.974,40-40 c22.091,0,40,17.909,40,40S182.171,128.16,160.08,128.16z" ] [] ] ], g [] [ g [] [ rect [ x "264.08", y "0.16", width "16", height "16" ] [] ] ], g [] [ g [] [ rect [ x "264.08", y "32.16", width "16", height "40" ] [] ] ], g [] [ g [] [ rect [ x "296.08", y "0.16", width "16", height "16" ] [] ] ], g [] [ g [] [ rect [ x "296.08", y "32.16", width "16", height "40" ] [] ] ] ]
