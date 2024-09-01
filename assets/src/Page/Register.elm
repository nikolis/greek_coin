module Page.Register exposing (Model, Msg, init, subscriptions, toSession, update, view, viewModal)

import Api exposing (Cred)
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, decodeString, field, string)
import Json.Decode.Pipeline exposing (optional)
import Json.Encode as Encode
import Route exposing (Route)
import Session exposing (Session)
import Viewer exposing (Viewer)
import Http.Legacy
import Http.Detailed
import Api2.Happy exposing (getBaseUrl)
import Dict exposing(Dict)
import Bootstrap.Modal as Modal
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Bootstrap.Grid as Grid
import Route exposing (Route)
import Loading
import Browser.Navigation as Navigat

-- MODEL
type alias ChangesetError =
    {
        error : Dict String (List String)
    }


type alias Model =
    { session : Session
    , problems : List Problem
    , updatePassResp : Maybe (List String)
    , modalVisibility : Modal.Visibility
    , form : Form
    , modalWindow : ModalWindow
    , visible : Bool
    , loading : Bool
    }

init : Session -> ( Model, Cmd msg )
init session =
    ( { session = session
      , problems = []
      , updatePassResp = Nothing 
      , modalVisibility = Modal.hidden
      , modalWindow = Closed
      , visible = False
      , loading = False
      , form =
            { username = ""
             , termsCond = False
             , credential = {
                  email = ""
                , password = ""
                , password_confirmation = ""
              }
            }
      }
    , Cmd.none
    )


type alias Form =
    { 
     username : String
    ,credential : Credentials
    , termsCond : Bool
    }

type alias Credentials = 
    { email : String
    , password : String
    , password_confirmation : String
    } 

type Problem
    = InvalidEntry ValidatedField String
    | ServerError String

type ModalWindow = 
    Errors String 
    | Success
    | Closed 


-- VIEW
view : Model -> Html Msg
view model =
        div [ class "cred-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col" ]
                        [  ul [ class "error-messages" ]
                          (List.map viewProblem model.problems)
                        , case model.loading of
                            True ->
                                viewLoading
                            False ->
                                viewForm model.form model
                        ]
                    ]
                ]
            ]

viewLoading : Html Msg
viewLoading = 
    div[style "width" "60%", style "height" "60%", style "margin" "auto"]
    [
        img[src "images/loading.svg"][]
     ]
viewForm : Form -> Model -> Html Msg
viewForm form model =
    let
        attrs = 
            case model.visible of
                False ->
                    type_ "password"
                True ->
                    type_ "text"
    in
    Html.form [ onSubmit SubmittedForm ]
        [ div [ class "row", style "border-style" "solid", style "border-color" "rgb(239, 239, 239)", style "border-radius" "20px", style "margin-left" "0.2vw", style "margin-right" "0.2vw"]
          [
           div[class "col-10"]
           [
               label [style "color" "rgba(112,112,112,1)", style "font-weight" "bold", value "Email", class "form-control form-control-lg", style "border-style" "none"][text "Email"]
            ,  input
                [ class "form-control form-control-lg"
                , placeholder "example@mail.com"
                , onInput EnteredEmail
                , value form.credential.email
                , style "border-style" "none"
                ]
                []
            ]
           , div[class "col justify-content-center align-self-center"]
             [
                 img[class "align-middle", src "/images/user.svg", style "width" "2vw", style "margin" "auto"][]
             ]
           ]
       , div [ class "row", style "border-style" "solid", style "border-color" "rgb(239, 239, 239)", style "border-radius" "20px", style "margin-left" "0.2vw", style "margin-right" "0.2vw", style "margin-top" "2vh", style "margin-bottom" "2vh"]
          [
           div[class "col-10"]
           [
               label [style "color" "rgba(112,112,112,1)", style "font-weight" "bold", value "Password", class "form-control form-control-lg", style "border-style" "none"][text "Password"]
            ,  input
                [ attrs, class "form-control form-control-lg"
                , onInput EnteredPassword
                , value form.credential.password
                , style "border-style" "none"
                ]
                []
            ]
           , div[class "col justify-content-center align-self-center"]
             [
                 img[class "align-middle", src "/images/password.svg", style "width" "2vw", style "margin" "auto", onClick ChangeVisble][]
             ]
           ]
          {--
        , div [ class "row", style "border-style" "solid", style "border-color" "rgb(239, 239, 239)", style "border-radius" "20px", style "margin-left" "0.2vw", style "margin-right" "0.2vw", style "margin-top" "2vh", style "margin-bottom" "2vh"]
          [
           div[class "col-10"]
           [
               label [style "color" "rgba(112,112,112,1)", style "font-weight" "bold", value "Password", class "form-control form-control-lg", style "border-style" "none"][text "Password"]
            ,  input
                [ type_ "password", class "form-control form-control-lg"
                , onInput EnteredPasswordConfirmation
                , value form.credential.password_confirmation 
                , style "border-style" "none"
                ]
                []
            ]
           , div[class "col justify-content-center align-self-center"]
             [
                 img[class "align-middle", src "/images/password.svg", style "width" "2vw", style "margin" "auto"][]
             ]
           ]--}
           , div[style "margin" "auto", style "width" "70%"]
             [
               input[type_ "checkbox",style "margin" "auto", style "margin-right" "0.25vw", style "width" "2vw", style "height" "2vh", style "color" "rgb(0, 99, 166)", onClick AgreedTerms, checked model.form.termsCond][] 
             , span[][text "I have read and agree to the "]
             , a[Route.href Route.Settings, style "color" "rgb(0, 99, 166)", style "font-weight" "bold"] [text "Terms of Use"]
             ]
           , div[class "input-group", style "margin-top" "2vh"]
             [ 
               button [ type_ "button", style "width" "30%" , style "margin" "auto", class "btn btn-primary primary_button", onClick SubmittedForm ]
               [ text "Register" ]
            ]

        ]

            
viewProblem : Problem -> Html msg
viewProblem problem =
    let
        errorMessage =
            case problem of
                InvalidEntry _ str ->
                    str

                ServerError str ->
                    str
    in
    li [] [ text errorMessage ]



-- UPDATE


type Msg =
      SubmittedForm
    | EnteredEmail String
    | EnteredUsername String
    | EnteredPassword String
    | CompletedRegister (Result (Http.Detailed.Error String) ( Http.Metadata, String ))
    | GotSession Session
    | CloseModal
    | CloseModalSuccess 
    | ShowModal
    | AgreedTerms
    | ChangeVisble

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AgreedTerms -> 
            let
               var =  model.form.termsCond
               formOld = model.form 
               formNew = {formOld | termsCond = not var}
            in
            ({model | form = formNew}, Cmd.none)

        ChangeVisble ->
            ({model | visible = not model.visible}, Cmd.none)

        SubmittedForm ->
            case validate model.form of
                Ok validForm ->
                    ( { model | problems = [], loading = True }
                    ,  (register validForm)
                    )

                Err problems ->
                    ( { model | problems = problems }
                    , Cmd.none
                    )

        EnteredUsername username ->
            updateForm (\form -> { form | username = username }) model

        EnteredEmail email ->
            let
                cred_old = model.form.credential 
                cred = {cred_old | email = email}
            in
            updateForm (\form -> { form | credential = cred }) model

        EnteredPassword password ->
            let
                cred_old = model.form.credential 
                cred = {cred_old | password = password}
            in
            updateForm (\form -> { form | credential = cred }) model

{--        EnteredPasswordConfirmation password_conf ->
            let
                cred_old = model.form.credential
                cred = {cred_old | password_confirmation = password_conf}
            in
            updateForm (\form -> { form | credential = cred }) model--}

        CompletedRegister (Err error) ->
           case error of
               Http.Detailed.BadStatus metadata body ->
                 let
                   md =  
                     case Decode.decodeString decoderChangeset body of
                       Ok errorBody ->
                           let
                             dictComp = Dict.map (\k b -> List.map (\c -> (k,c)) b ) errorBody.error
                             values = Dict.values dictComp
                             listClean = List.concat values
                             list = List.map (\(a,b) -> a++": "++ b) listClean

                             listStr = List.map (\(a,b) -> a++": " ++b) listClean
                             errorStr = List.foldr (++) "" listStr
                           in

                          {model | modalWindow = Errors errorStr, loading = False}

                       Err error2 ->
                          {model | modalWindow = Errors body, loading = False}
                 in
                 ({md | loading = False}, Cmd.none)

               Http.Detailed.Timeout ->
                  let
                   md = {model | modalWindow = Errors "server timeout please try later", loading = False}
                 in
                 update ShowModal md
               _ ->
                 ({model| loading = False }, Cmd.none)

        CloseModalSuccess ->
          ({model | modalWindow = Closed, updatePassResp = Nothing},Navigat.load (Route.routeToString Route.Home ))
          
        CloseModal ->
          ({model | modalWindow = Closed, updatePassResp = Nothing}, Cmd.none)
       
        ShowModal ->
          ({ model | modalVisibility = Modal.shown}, Cmd.none) 

        CompletedRegister (Ok (metadata, response)) ->
           let
             md = { model | updatePassResp = Just [response], loading = False} 
           in
           ({md | modalWindow = Success}, Cmd.none) 


        GotSession session ->
            ( { model | session = session }
            , Route.replaceUrl (Session.navKey session) Route.Home
            )


{-| Helper function for `update`. Updates the form and returns Cmd.none.
Useful for recording form fields!
-}
updateForm : (Form -> Form) -> Model -> ( Model, Cmd Msg )
updateForm transform model =
    ( { model | form = transform model.form }, Cmd.none )

viewModal : Model -> Maybe (Html Msg)
viewModal model = 
    case model.modalWindow of 
        Closed ->
            Nothing
        Errors theError ->
            Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Registration Error"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col", style "text-align" "center"]
                          [
                              span[class "modal_message"][text theError]
                          ]
                      ]
                  ,  div[class "row"]
                     [
                         div[class "col"]
                         [
                           button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModal, class "btn btn-primary primary_button"][text "OK"]
                         ] 
                     ]
                  ]
                )

        Success ->
            Just(
                  div[class "container"]
                  [
                      div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_header center-block"][text "Registration Success"]
                          ]
                      ]
                  ,   div[class "row"]
                      [
                          div[class "col"]
                          [
                              span[class "modal_message"][text "An email has been sent to your registered email address with a link to verify your email"]
                          ]
                      ]
                  ,  div[class "row"]
                     [
                         div[class "col"]
                         [
                           button [type_ "button", style "width" "40%" , style "margin" "auto", style "padding" "10px 3px", onClick CloseModalSuccess, class "btn btn-primary primary_button"][text "OK"]
                         ]
                     ]
                  ]
                )

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
-- FORM


{-| Marks that we've trimmed the form's fields, so we don't accidentally send
it to the server without having trimmed it!
-}
type TrimmedForm
    = Trimmed Form


{-| When adding a variant here, add it to `fieldsToValidate` too!
-}
type ValidatedField
    = Username
    | Email
    | Password
    | TermsCond


fieldsToValidate : List ValidatedField
fieldsToValidate =
    [ Username
    , Email
    , Password
    , TermsCond
    ]


{-| Trim the form and validate its fields. If there are problems, report them!
-}
validate : Form -> Result (List Problem) TrimmedForm
validate form =
    let
        trimmedForm =
            trimFields form
    in
    case List.concatMap (validateField trimmedForm) fieldsToValidate of
        [] ->
            Ok trimmedForm

        problems ->
            Err problems


validateField : TrimmedForm -> ValidatedField -> List Problem
validateField (Trimmed form) field =
    List.map (InvalidEntry field) <|
        case field of
            Username ->
                if String.isEmpty form.username then
                    []

                else
                    []

            TermsCond ->
                if form.termsCond == False then
                    ["You have to agree with the terms and conditions to continue"]

                else
                    [] 


            Email ->
                if String.isEmpty form.credential.email then
                    [ "email can't be blank." ]

                else
                    []

            Password ->
                if String.isEmpty form.credential.password then
                    [ "password can't be blank." ]

                else if String.length form.credential.password < Viewer.minPasswordChars then
                    [ "password must be at least " ++ String.fromInt Viewer.minPasswordChars ++ " characters long." ]

                else
                    []


{-| Don't trim while the user is typing! That would be super annoying.
Instead, trim only on submit.
-}
trimFields : Form -> TrimmedForm
trimFields form =
    Trimmed
        { username = String.trim form.username
          , termsCond = form.termsCond
          , credential = {
            email = String.trim form.credential.email
           , password = String.trim form.credential.password
           , password_confirmation = String.trim form.credential.password_confirmation
          }
        }



-- HTTP

credEncoder : Credentials ->  Encode.Value
credEncoder cred = 
    Encode.object 
    [ ("email", Encode.string cred.email)
     ,("password", Encode.string cred.password)
    ]

decoderChangeset : Decoder ChangesetError
decoderChangeset =
    Decode.succeed ChangesetError
    |> Json.Decode.Pipeline.required "errors" (Decode.dict (Decode.list string))

register :TrimmedForm -> Cmd Msg
register (Trimmed form)   =
    let
        user =
            Encode.object
                [ ( "username", Encode.string form.username )
                , ( "credential", credEncoder form.credential) 
                ]

        body =
            Encode.object [ ( "user", user ) ]
                |> Http.jsonBody
    in
    Http.request
    {
     headers =  []
    , method = "POST"
    , body = body
    , url = (getBaseUrl ++ "/api/v1/users")
    , expect = Http.Detailed.expectString  CompletedRegister 
    , timeout = Nothing
    , tracker = Nothing
    }
