module Page.Article exposing (Model, Msg, init, subscriptions, toSession, update, view)

{-| Viewing an individual article.
-}

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Avatar
import Browser.Navigation as Nav
import CommentId exposing (CommentId)
import Html exposing (..)
import Html.Attributes exposing (attribute, class, disabled, href, id, placeholder, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode as Decode
import Loading
import Log
import Page
import Profile exposing (Profile)
import Route
import Session exposing (Session)
import Task exposing (Task)
import Time
import Timestamp
import Username exposing (Username)
import Viewer exposing (Viewer)
import Http.Legacy


-- MODEL

type alias Model =
    { session : Session
    }




type CommentText
    = Editing String
    | Sending String


init : Session  -> ( Model, Cmd Msg )
init session  =
    let
        maybeCred =
            Session.cred session
    in
    ( { session = session
      }
    , Cmd.batch
        [ 
        ]
    )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Something"
    , content = div [class "container"]
      [ h1[][text """KYC/AML/CTF policy
Know Your Customer (KYC)
Anti-Money Laundering (AML) & Combating Terrorist Financing (CTF) Policy
***********************"""]
      , h2[][text "1. PREAMBLE"]
      , p[][text """“GREEK COIN OÜ” is committed to high standards of Know Your Customer, Anti-Money Laundering and Combating Terrorist Financing (hereinafter collectively referred to as KYC/AML/CTF) compliance and requires its clients to adhere to these standards before any transaction, in order to prevent use of the services for money laundering purposes, terrorist financing and other illegal activities.
Know your customer (KYC) is the process of a business identifying and verifying the identity of its clients. Know your customer processes are also employed by companies of all sizes for the purpose of ensuring their agents, consultants, or distributors are anti-bribery compliant. For instance, banks, insurers and export creditors are increasingly demanding that customers provide detailed anti-corruption due diligence information.
For the purposes of a KYC policy, a Customer/user may be defined as a person or entity that maintains an account and/or has a business relationship with “GREEK COIN OÜ”; one on whose behalf the account is maintained (i.e. the beneficial owner); beneficiaries of transactions conducted by professional intermediaries such as stockbrokers, as permitted under the law; or any person or entity connected with a financial transaction which can pose significant reputational or other risks to “GREEK COIN OÜ”, for example, issue of a high-value demand draft as a single transaction.
Virtual currencies are developing quickly and are an example of digital innovation. However, at the same time, there is a risk that virtual currencies could be used by terrorist organisations to circumvent the traditional financial system and conceal financial transactions as these can be carried out in an anonymous manner. “GREEK COIN OÜ” applies customer due diligence in order to contribute to preventing money laundering and terrorist financing, takes preventive measures and reports suspicious transactions to public authorities.
The policy on Prevention of Money Laundering and Terrorist Financing outlines the minimum standards of AML/CTF control, which should be adopted by the Clients in order to mitigate the legal, regulatory, reputational and subsequent financial risks."""]
      ,h2[][text " 2. IDENTIFICATION METHODS"]
      ,p[][text """Applying its KYC/AML/CTF policy, “GREEK COIN OÜ” will need to ask from its clients to identify themselves. Identifying the client might contain identifying and verifying the client’s identity on the basis of documents, data or information obtained from a reliable and independent source. Purpose of the transaction is established where applicable. Moreover, it is highly possible that, in case of ML/TF suspicion at any time, regardless of any derogation, exemption or threshold, “GREEK COIN OÜ” asks for further identification widening customer verification requirements, without prior notice, or might even indiscriminately refuse any transaction.
“GREEK COIN OÜ” collects identification data of every Client, as well as IP addresses, online activity, communications and in general, all transactions carried out by the Client. Moreover, clients will be required to identify themselves by means of identification documents such as government-issued photo ID, proof of residential or business address, corporate documentation, business registration information, tax Identification Document, employer Identification Number, or any other applicable documentation. The above-mentioned list is not exhaustive. “GREEK COIN OÜ” will ask for identification documents that are absolutely necessary for the abovementioned purposes, depending each time on the ongoing transaction, and not all of these documents.
Termination of account will occur in case of deceptive documentation, false contact details and business description or other false information, and the account will be considered as offensive. Furthermore, providing false or deceptive documents is considered as fraud and will be treated as such."""]
     , h2[][text "3. AML/CTF Measures"]
     ,p[][text """
     “GREEK COIN OÜ” is not the only entity that implements KYC/AML/CTF policy and measures. Such measures are also taken and implemented by international and national institutions, banking and business community in general.
“GREEK COIN OÜ” monitors and tracks all transactions. In case of suspicious activities of its clients, “GREEK COIN OÜ” especially tracks unusual transactions such as irrational transactions, large transactions, transactions involving unidentified parties etc. Moreover, “GREEK COIN OÜ” might apply enhanced customer due diligence measures to manage and mitigate risks with regards to high-risk third countries. Enhanced customer due diligence measures may contain obtaining additional information on the customer, obtaining additional information on the intended nature of the business relationship, obtaining information on the source of funds or source of wealth of the customer, obtaining information on the reasons of the intended or performed transactions, to name but a few.
Please, keep in mind that any information pointing to money laundering or terrorist financing must be reported to the relevant authorities, without client’s prior notice. This includes report to the Financial Intelligence Unit (FIU) or other law enforcement authorities.
FIU is a public authority. Such public authorities exist in every Member State. They collect and analyse information about any suspicious transactions spotted by banks, for instance, or any other relevant information related to money laundering or terrorism financing. If their analysis of file raises concerns regarding possible criminal activity, they transfer the file to law enforcement authorities for further action.
It might need that the Financial Intelligence Units (FIUs) has enhanced access to – and exchange of – information in various ways for example by introducing centralised bank and payment account registers, or by aligning the rules for Financial Intelligence Units (FIUs) with the latest international standards.""" ]
    ,h2[][text "4. PERSONAL DATA PROTECTION"]
    ,p[][text """
    The fact that “GREEK COIN OÜ” implements KYC/AML/CTF policies does not mean that it deliberately share your personal data. Your identification data will be collected, processed and stored only by “GREEK COIN OÜ”, and no third parties will have access to it, except from public authorities in case of suspicious transactions of any kind.
“GREEK COIN OÜ” keeps records of all transactions and all identification documents, and will retain all information, including those obtained through electronic identification means for a period of at least five (5) years after the end of the business relationship with the client or after the date of an occasional transaction. Personal data is considered as confidential and “GREEK COIN OÜ” will never disclose personal data to third parties, unless otherwise is stipulated by the Applicable Legislation. Personal data will be processed only for the transaction purposes and for purposes of the prevention of money laundering and terrorist financing and not in ways incompatible with those purposes, such as commercial purposes. Finally, “GREEK COIN OÜ” might sometimes share such data with public authorities (such as FIUs).
        """]
    ,h2[][text "5. APPLICABLE LAW"]
    ,p[][text """
    These terms and conditions and any amendments thereto, and any transaction thereunder, are governed by Greek law and European Legislation. The invalidity of one of these terms does not affect the validity and effect of the rest of the terms.
For any dispute arising from the use of the machine, the Courts of Tallin, Estonia are designated as exclusively competent jurisdiction.
Provisions of the Law on consumer protection are not affected by these terms and conditions, but are still valid.
"""]
     ,h2[][text "6. FINAL NOTICE"]
     ,p[][text """
     “GREEK COIN OÜ” improves its KYC/AML/CTF procedures continuously to monitor unlawful financial schemes and clients are obliged to read them on their own responsibility before each and every transaction."""
     ]
      ]
      
    }



type Msg
    = GotSession Session

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of 
        GotSession session->
         ({model| session = session}, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- HTTP


toSession : Model -> Session
toSession model =
    model.session

-- INTERNAL

