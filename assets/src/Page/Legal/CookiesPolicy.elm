module Page.Legal.CookiesPolicy exposing (..)

import Session exposing (Session)
import Html exposing (..)
import Html.Attributes exposing (class, classList, href, style)
import Page.Home.Naview as Nav
import Svg exposing (svg, rect)
import Svg.Attributes
import Page.Home.Packages exposing (viewGettingStarted)
import Page.Home.Packages as PackagesP

type alias Model =  
    {
        session : Session
    }

type Msg = 
  GotSession Session



init : Session -> (Model, Cmd Msg)
init session = 
    let
        md = { session = session}
    in
    (md, Cmd.batch [Cmd.none])


view : Model -> {title : String, content: Html Msg}
view model = 
    { title = "Cookies Policy"
    , content = 
      div[class ""]
        [ 
         div[style "margin-left" "-15px",style "background-image" "url(\"images/crupto_2.png\")", style "background-repeat" "no-repeat", style "background-size" "cover", style "margin-top" "-5px", style "padding-right" "100px"]
         [
             div[class "col", style "margin-right" "10vw"]
             [
              Nav.naview model.session 2
             ]
         , div[class "row"]
           [
               div[class "col", style "margin-left" "10vw"]
               [
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Cookies Policy"]
{--               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "Let's schedule together"]
               , br[][]
               , span[style "font-size" "2rem", style "color" "rgba(255,158,46,1)"][text "your next step in Cryptocurrency"]--}
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
       , div[class "container"]
         [
             div[class "row"]
             [
                 div[class "col"]
                 [
                    h3[style "font-weight" "bold"][text " Greek Coin OÜ Cookies Policy"]
                 ]
             ]

          ,  div[class "row"]
             [
                 div[class "col"]
                 [
                         
   ol[class " countable "][li[][text """General Information 

        """ 
      , ol[class "countable"][li[][text """This Privacy Policy explains how Greek Coin OÜ and its Affiliates (hereinafter “Greek Coin OÜ” “we,” “us,” and “our”) collects, uses, shares, and protects user information obtained through the greek-coin.com website. When we ask for certain personal information from users it is because we are required by law to collect this information or it is relevant for specified purposes. 
        """] 
          , li[][text """Any non-required information you provide to us is done so voluntarily. You decide whether to provide us with this non-required information, but you may not be able to access or utilize all of our Services if you choose not to.
        """] 
          , li[][text """By accepting the Personal Data notification while using the Site, you consent to the data practices described in this Privacy Policy, as well as when you register for an account. On occasion, Greek Coin OÜ may revise this Privacy Policy to reflect changes in law or our personal data collection and use practices. If material changes are made to this Privacy Policy, the changes will be announced by posting on the site. We will ask for your consent before using your information for any purpose that is not covered in this Privacy Policy.
        """] 
          , li[][text """The Privacy Policy has incorporated elements from the General Data Protection Regulation (GDPR) as we act in accordance to its personal information processing rules within the European Economic Area (EEA).
        """] 
          , li[][text """This Privacy Policy was made on the basis of:
            """ 
      , ol[class "countable"][li[][text """Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of individuals with regard to the processing of personal data and on the free movement of such data and repealing Directive 95/46 / EC (General Data Protection Regulation), hereinafter also referred to as “GDPR”.
            """] 
          , li[][text """DIRECTIVE (EU) 2015/849 of the European Parliament and of the Council of 20 May 2015 on the prevention of the use of the financial system for the purposes of money laundering or terrorist financing (hereinafter referred as Directive),
            """] 
          , li[][text """National provisions in force in the Republic of Estonia.

      """] ] ]  ] ]  
    , li[class "countable"][text """Definitions and legal references

        """ 
      , ol[class "countable"][li[][text """Personal data (or data): Any information that directly, indirectly or in relation to other information - including a personal identification number - allows the identification or identification of a natural person.
        """] 
          , li[][text """Usage data: Information collected automatically through this Site (or third party services used on this Site), which may include: the IP addresses or domain names of the computers used by the Users using this Website, the URIs ( Uniform Resource Identifier), at the time of the request, the method used to submit the request to the server, the size of the file received in response, the numeric code indicating the status of the server response (successful outcome, error, etc.), the source country, the browser and operating system functions used by the User, the various time-per-visit details (e.g., time spent on each page of the Application), and details of the route followed in the Application with special reference to the sequence, the pages you have visited, and other Measures relating to the operating system of the device and / or the user's IT environment.
        """] 
          , li[][text """Data subject: The person who uses this Site and which, unless otherwise specified, coincides with the Underlying Data.
        """] 
          , li[][text """Data processor (or data controller): The individual or legal person, public authority, organization or other entity processing personal data on behalf of the auditor as described in this privacy policy.
        """] 
          , li[][text """Data controller (or owner): An individual or legal person, a public authority, an organization or other entity which, either alone or together with others, determines the purposes and means of processing the Personal Data, including security measures relating to its operation and use Website. The Data Controller, unless otherwise specified, is the owner of this Site.
        """] 
          , li[][text """This site (or this app): The means by which the User's Personal Data is collected and processed.
        """] 
          , li[][text """Service: The service provided by this site as described in the relevant terms (if available) and on this site/ application.
        """] 
          , li[][text """European Union (or EU): Unless otherwise stated, all references made in this document to the European Union include all the current Member States in the European Union and the European Economic Area.
        """] 
          , li[][text """Legal information: This privacy statement has been prepared on the basis of provisions of many laws.13/ 14 of Regulation (EU) 2016/679 (General Data Protection Regulation). This privacy policy is strictly related to this site.

     """] ] ]  
    , li[class "countable"][text """Administrator of Personal Data

        """ 
      , ol[class "countable"][li[][text """The person responsible for collecting and processing personal data on the site greek-coin.com is "GREEKCOIN OÜ" has been set up and complies with the Laws of the Estonian Republic, with Registration code 14787392, with headquarters in Estonia, Tallinn, Kesklinna linnaosa, Roseni tn 13, 10111, e-mail: info@greek-coin.com. If you have any questions, requests or complaints regarding the processing of your personal data by us, you can also contact George Svarnas using the following e-mail: George_Svarnas@greek-coin.com or tel.: +3726023530.
        """] 
          , li[][text """Questions, applications and complaints referred to in the preceding paragraphs should, in particular include:
            """ 
      , ol[class "countable"][li[][text """data relating to the person or persons concerned by the inquiry or request,
            """] 
          , li[][text """the event which is the reason for sending a message to us,
            """] 
          , li[][text """requests and legal grounds for demanding request,
            """] 
          , li[][text """the expected manner of handling the matter.

      """] ] ]  ] ]  
    , li[class "countable"][text """Purpose and method of collection

        """ 
      , ol[class "countable"][li[][text """Visiting and using our Website is associated with the need to collect and process your personal data.
        """] 
          , li[][text """Please note, we process your personal data, in particular, the data you provide us with when setting up and verifying your account on our Website and the data you generate using services offered by our Website (e.g. sending orders, making purchases, exchanging digital assets, etc.).
        """] 
          , li[][text """We need to comply with global industry regulatory standards including Anti-Money Laundering (AML), Know-Your-Customer (KYC), and Counter Terrorist Financing (CTF) with formal identification and collect such a wide range of information to fulfil the binding legal provisions regarding the obligation to identify the client, to monitor the transactions, combat and assess the risks of fraud, money laundering, financing of terrorism. Therefore, if you do not provide the data requested during the registration and verification, or if the data proves to be false, or if you object to its processing, we will not be able to continue to provide you with our services. In order to verify the accuracy of the data provided by you and to assess the risk of fraud, we also monitor your transaction history by analyzing the course, volume, currency and type of transactions.
You can read more in our AML/KYC Policy. 
        """] 
          , li[][text """If you express a wish to use additional services offered by us, we will process your data which we collected in order to provide our services, in compliance with their description contained in the Terms and Conditions or provided to you separately. These services may include among others: newsletter, contests, etc.
        """] 
          , li[][text """We keep all of your information strictly confidential and use it only for the purposes for which we informed you when we collected it or in this Privacy Policy. 
        """] 
          , li[][text """As part of the operation of our Website, you may be asked to provide us with the following personal data:
            """ 
      , ol[class "countable"][li[][text """name 
            """] 
          , li[][text """date of birth 
            """] 
          , li[][text """address and country of residence 
            """] 
          , li[][text """nationality 
            """] 
          , li[][text """phone number 
            """] 
          , li[][text """information concerning the identity document (passport or identity card or driving license) 
            """] 
          , li[][text """photo 
            """] 
          , li[][text """bank account number 
            """] 
          , li[][text """Personal (national) Identification Number 
            """] 
          , li[][text """e-mail address 
            """] 
          , li[][text """IP address (Internet Protocol) of your device 
            """] 
          , li[][text """Bitcoin Address or other cryptocurrencies addresses
            """] 
          , li[][text """Other data necessary for the identification of the new Client or the identification of the source of wealth, for verification and AML compliance purposes. 
            """] 
          , li[][text """other data such as – ​ request URL, domain name, device ID, browser type, browser language, number of clicks, amount of time spent on individual pages, date and time stamp of using the Website, type and version of the operating system, screen resolution, data collected in the server logs, and other similar information to develop statistical data for the optimization of services rendered, including displaying content that complies with your preferences.
         """] ] ]  
          , li[][text """Providing your personal data indicated in the preceding point is necessary in the following cases:
            """ 
      , ol[class "countable"][li[][text """to create​ a user account on our Website, and to use​ the full functionality of it;
            """] 
          , li[][text """all data provided to us for the purpose of setting up a user account may be used for the purposes of the affiliate​ programs​ provided that you have given us your consent and wish to participate,
            """] 
          , li[][text """in order to respond​ to inquiries addressed to us via our contact details; 
            """] 
          , li[][text """in order to provide​ the newsletter service,​ if you want to be informed on an ongoing basis what is up to date with us and what news we have prepared for you, you can become a subscriber to our newsletter, subscription is voluntary and you can unsubscribe from it at any time.
         """] ] ]  
          , li[][text """Personal data are processed by our Company primarily in order to provide you with our services you order and any additional issues features within our Website. However, we would like to emphasize that as an Administrator we take care to observe the principle of minimizing and process only those categories of personal data that are necessary for us to achieve these goals.
        """] 
          , li[][text """Each person using our Website has a choice whether, and if so, to what extent they want to use our services and what data about themselves they want to share with us within the scope of this Privacy Policy.
        """] 
          , li[][text """When you contact us in order to perform various activities or to obtain information (e.g. to submit a complaint) using the Website, telephone or e-mail, we will again require you to provide us with your personal data to confirm your identity and the possibility of return contact.

     """] ] ]  
    , li[class "countable"][text """Usage and legal basis

        """ 
      , ol[class "countable"][li[][text """Your personal data is always processed on one of the following legal bases:
            """ 
      , ol[class "countable"][li[][text """your consent; 
            """] 
          , li[][text """an agreement concluded between us;
            """] 
          , li[][text """legal obligation, i.e. an obligation arising from legal acts – in the scope necessary to comply with the binding provisions;
            """] 
          , li[][text """our legally legitimate interest.
         """] ] ]  
          , li[][text """If we process your personal data on the basis of the consent referred to in point 4.1.1) above, the data you provide is used only for the purposes covered by your consent. On this basis, we will primarily carry out information and marketing campaigns. Remember that at any time you can change your mind and withdraw your consent – just send us an e-mail. ​ Please​ note, however, that this does not always involve the deletion of your personal data. We may still process your personal data if it is necessary, e.g. if we have another legal basis for processing your personal data (concluded contract) or if we have a legitimate legal obligation to do so.
        """] 
          , li[][text """Whether you have given us your consent for the processing of your personal data or we are bound with you by a contract, we will also have to process your data due to the need to comply with our legal obligations. These will be situations in which, for example, we must store data resulting from transactions made for tax and accounting reasons; as well as situations where we are obliged to verify and analyse your data (including your actions taken on the Website) in accordance with applicable anti-money laundering and terrorist financing regulations.
        """] 
          , li[][text """Based on our legitimate interest, we will process your data for the purpose of claiming our rights and defending ourselves against claims, for evidentiary and archival purposes. On the same basis, we will also process your personal data collected automatically on the Website in order to ensure the security of the session, quality of the session and provide you with all the functions of the Website. On this basis, we will also process your personal data for analytical purposes, which will involve the examination and analysis of traffic on our Website.

     """] ] ]  
    , li[class "countable"][text """Protection of Personal Data

        """ 
      , ol[class "countable"][li[][text """ We ensure an optimal range of organizational measures in a manner that ensures its proper protection, in particular:
            """ 
      , ol[class "countable"][li[][text """secure the possibility of collecting, copying and disclosing personal data to unauthorized persons
            """] 
          , li[][text """protect personal data, databases and devices on which personal data are processed from loss, damage or destruction.
         """] ] ]  
          , li[][text """We store, use and transmit your data in a manner that ensures its proper protection, including protection against unauthorized or unlawful processing and accidental loss, destruction or damage, by means of appropriate technical and organizational measures
        """] 
          , li[][text """We have implemented a number of security measures to ensure that your information will not be lost, used or changed. Our data security measures include, among others: encryption, regular data backup and testing, measuring and assessing the effectiveness of security measures used, https protocol, restrictions on access to internal data.
        """] 
          , li[][text """Access to data processed by us is carried out through an internal network, secured by our certificates and keys, thus excluding third party access “from outside” as well as “our” unauthorized persons.
        """] 
          , li[][text """In order to secure your data, we have developed and are constantly improving our own original script that encrypts data.
        """] 
          , li[][text """When we store your data on internal servers, we do it through entities that guarantee security of the infrastructure offered (ISO / IEC 27001:2014 certification,) who have a good opinion, and their services are used by other entities processing personal data of special importance. For this reason, the servers used by us are located in several places in Europe. 
        """] 
          , li[][text """Regardless of the above, please remember that it is impossible to guarantee a completely secure data transmission over the Internet or electronic data storage methods. Therefore, we ask that you also take reasonable precautions to protect your personal data. If you suspect that your personal information has been compromised, in particular, the account or password information has been disclosed, contact us immediately.
        """] 
          , li[][text """Detailed IT solutions protecting your data are confidential, making it difficult to break them.

     """] ] ]  
    , li[class "countable"][text """Duration of record keeping

        """ 
      , ol[class "countable"][li[][text """We store and process your data only as long as it is necessary for the purpose for which it was obtained.
        """] 
          , li[][text """You should be aware that your personal data may be processed by us for a longer period (up to 5 years) than indicated above. This is due to the obligations imposed on us and specific legal provisions.
        """] 
          , li[][text """If the basis for processing your data is:
            """ 
      , ol[class "countable"][li[][text """your consent – this period lasts until you withdraw your consent or until the expiry of your consent (e.g. when the consent concerned a service that we no longer provide), if further processing of your personal data does not impose any obligation on us or does not result from specific legal regulations
            """] 
          , li[][text """the need to execute an agreement – Please remember that not always the period of processing your data lasts as long as the parties are bound by the concluded contract, due to the obligations imposed on us by specific legal provisions, e.g. the obligation to keep accounting books and records may be extended accordingly.
            """] 
          , li[][text """legal obligation – Your personal data will be processed for as long as we are under a legal obligation to do so in accordance with specific legal provisions;
            """] 
          , li[][text """the pursuit of legitimate interest – until the interest persists.
         """] ] ]  
          , li[][text """Of time is primarily due to special regulations. Therefore, even though you withdraw your consent, the contract that linked us will be terminated or simply expire, in some cases, we are still required to process your personal data.
For example:
            """ 
      , ol[class "countable"][li[][text """data provided for account registration on the Website will be stored for as long as your account will be kept – that is, until you do not cancel it or request it to be closed unless further processing of your personal data is necessary to comply with a legal obligation;
            """] 
          , li[][text """data provided for the Newsletter or other mailing to be sent will be kept until your consent for their delivery is valid
            """] 
          , li[][text """if you gave consent to our other information activities about our offer – your data necessary for performing such activities will be kept until you withdraw your consent.
         """] ] ]  
          , li[][text """Due to the fact that our services, among others, are subject to regulations of the Directive, we are obliged to keep for at least five years from the end of our economic relations with you (i.e. from the final closing and settlement of the account), including:
            """ 
      , ol[class "countable"][li[][text """copies of documents and information obtained in connection with the verification of your identity
            """] 
          , li[][text """copies of documents and information being the basis for assessing the risk of fraud in relation to your transactions;
            """] 
          , li[][text """evidence confirming transaction and transaction records necessary to identify transactions.
            """] 
          , li[][text """The retention period of your data required by law may be subject to change as the applicable law changes.
         """] ] ]  
          , li[][text """After the indicated time periods expire, your personal data will be deleted or anonymized in a way that prevents the data from being attributed to you.

     """] ] ]  
    , li[class "countable"][text """Necessity to provide your Personal Data

        """ 
      , ol[class "countable"][li[][text """In the case of registration and verification of an account, we process only the data without which the agreement concluded with you cannot be executed for “technical” reasons or for legal reasons. Not providing us with the required data will result in the fact that we will not be able to set up or keep your account, let alone carry out transactions within it.
        """] 
          , li[][text """Giving us your consent to the processing of your personal data is voluntary. If you do not give us your consent (or withdraw it), then we will not take any actions that a given consent applies to.

     """] ] ]  
    , li[class "countable"][text """Sharing information with 3rd parties 

        """ 
      , ol[class "countable"][li[][text """Entities providing hosting services for the website on which our Website is located – so that you can use our Website, create a user account, contact us in case of any questions;
        """] 
          , li[][text """Entities providing IT services for the website where our Website is located – if necessary, thanks to which our Website, and first of all your user account, can function efficiently, in this way we also remove all types of failures, defects, technical interruptions in the functioning of our Website;
        """] 
          , li[][text """Entities providing banking services – your order to deposit or withdraw funds requires entrusting your data to a bank;
        """] 
          , li[][text """Postal, courier and freight service providers – for the delivery of parcels – if you choose to participate in our contest or affiliate program, it is necessary for you to receive the prize;
        """] 
          , li[][text """Entities providing accounting services – in order to keep the accounting books of our company;
        """] 
          , li[][text """Entities verifying the authenticity of the documents that you provided to us – in order to carry out a procedure of proper identification of your identity;
        """] 
          , li[][text """Entities assessing the risk of fraud – in order to assess that risk;
        """] 
          , li[][text """Entities that provide other services to us that are necessary for the day-to-day operation of the Website.
        """] 
          , li[][text """Sharing your personal data - we make sure that the entities we cooperate with ensure the implementation of technical and organizational measures and process them in accordance with applicable regulations, including the provisions of the GDPR.
        """] 
          , li[][text """The fact that we entrust the processing of some of your personal data to third entities does not mean that we lose control over it. In relation to the data through us, you can still exercise your rights set out in this Privacy Policy. We make sure that they are used in accordance with the law and only to the extent to which we entrusted their processing to these entities.
        """] 
          , li[][text """Your personal data will not be transferred to third countries or international organizations in the meaning of GDPR regulations. In that case, you will be informed in advance and the Administrator undertakes to apply appropriate security measures in accordance with the GDPR
        """] 
          , li[][text """Some of the entities providing services to us have servers located outside of Estonia, but in each case, they are located in the countries within the European Union and they ensure proper protection of your data in accordance with EU regulations.

     """] ] ]  
    , li[class "countable"][text """Cookies

        """ 
      , ol[class "countable"][li[][text """ Our Website uses Cookies technology in order to adapt its operation to your individual needs. According to this, you may consent to the storage of the data and information entered by you, so that it can be used for future visits to our Website without the need to re-enter it. The owners of other websites will not have access to this data and information. However, if you do not agree to personalize the Website, we suggest disabling the use of cookies in the options of your Internet browser.
        """] 
          , li[][text """Learn more on our “Cookies” policy. 

     """] ] ]  
    , li[class "countable"][text """Personal Data Protection Rights 

        """ 
      , ol[class "countable"][li[][text """In connection with the processing of your data by us, you have a number of rights, which we inform you about in this section. You can exercise them, as well as obtain more information in this regard, by contacting us at the e-mail or correspondence address indicated on the Website. Please include the following information when contacting us:
            """ 
      , ol[class "countable"][li[][text """data of the person or persons concerned by the request or question
            """] 
          , li[][text """the event which is the reason for sending a message to us,
            """] 
          , li[][text """your requests and the legal basis for its requests,
            """] 
          , li[][text """the expected manner of handling the matter.
         """] ] ]  
          , li[][text """Due to the processing of your data by us, you have:
            """ 
      , ol[class "countable"][li[][text """The right to​ be informed about the processing of personal data – the Administrator is obliged to inform you about the fact that your personal data is being processed, for what purpose, indicate the appropriate legal basis for the processing, the period of processing and other information, including whether your personal data is being transferred or made available to third parties, in addition, such obligation must be fulfilled at the time of collecting personal data, that is why we have created this Privacy Policy.
            """] 
          , li[][text """the right to request access​ to your personal data – both the data you shared with us and which we are processing, as well as the data generated in the course of our cooperation (e.g. history of transactions);
            """] 
          , li[][text """the right to request immediate correction​ or upgrading of your personal data by us, if it is incorrect;
            """] 
          , li[][text """the right to complete​ incomplete personal data, including through the presentation of an additional statement (considering the purposes of processing);
            """] 
          , li[][text """the right to immediately delete​ your data (“the right to be forgotten”); – in such a case we will delete your data immediately (however, we will keep the data we must keep in compliance with the law);
            """] 
          , li[][text """the right to request processing restrictions​;
            """] 
          , li[][text """the right to receive​ data you provided to us in a structured commonly used format suitable for machine-reading and to send it to another administrator;
            """] 
          , li[][text """the right to transfer​ your personal data – you may demand that we transfer your data to another administrator of your choice, we may satisfy your request if you have given us your consent to the processing of your personal data
            """] 
          , li[][text """the right to object​ to the processing of your personal data for the needs of direct marketing which causes that we will cease to process your data for the purposes of direct marketing;
            """] 
          , li[][text """the right to object​ due to causes related to your particular situation, if your personal data is processed based on a legally justified interest. However, we will keep processing your personal data in the necessary scope if there is a particular justified reason for that for us – we will inform you about this in such a case;
            """] 
          , li[][text """if the basis for the processing of your personal data is your consent, you will have the right​ to withdraw such consent at any time. Withdrawal of your consent does not affect compliance with the law of processing of your personal data by us carried our based on the consent before its withdrawal.
         """] ] ]  
          , li[][text """Filing a complaint to the supervisory body – If you feel that the processing of your personal data by us violates the law, you can file a complaint to the supervisory body that deals with the protection of personal data.
        """] 
          , li[][text """You can submit a statement regarding the exercise of any of your rights mentioned above through our contacts found on the website. 
        """] 
          , li[][text """Withdrawing your consent or objecting to the processing of data, if you do not formulate any other objections, will affect all our services and Websites and the entities entrusted with the processing of your data.
        """] 
          , li[][text """Withdrawal of consent in relation to the terms of the Terms and Conditions and Privacy Policy will involve deleting your account on the Website and deleting personal data provided by you.
        """] 
          , li[][text """If you feel that the processing of your personal data by us violates the law, you can file a complaint to the supervisory body that deals with the protection of personal data. 

     """] ] ]  
    , li[class "countable"][text """Restriction of Responsibility

        """ 
      , ol[class "countable"][li[][text """Greek Coin OÜ shall not be held liable for any claim, damage or loss that was facilitated through sophisticated technological means that surpasses the common level of security provided by companies such ours. 
        """] 
          , li[][text """Greek Coin OÜ shall not be held liable for any claim, damage, or loss for any action or omission outside the power of control of the Company or it is based on Acts of God, including environmental disasters, cut of electricity, earthquakes, pandemics, and other phenomena. 
        """] 
          , li[][text """Greek Coin OÜ shall not be held liable for any claim, damage, or loss for any action that was initiated and/or instructed and/or executed by the User, and/or such action was in violation of any agreement, Policy, Regulation and/or circumvents such agreements, policies, regulations in bad faith, fraudulently and/or against the interests of the Company or its Operators. 
 """] ] ] ] 
                 ]
             ]
          ]
      ]
   }
 


viewSteper : Model -> Html Msg
viewSteper model=
          div[class "container_profile_header" ]
          [
            div [class "center_exchange"]
            [
              h1 [][ span[][ text "Cookes Policy"]]
            ]
          ]
 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
    case msg of 
      GotSession session ->
         ( { model | session = session }, Cmd.none
         )


toSession : Model -> Session
toSession model = 
    model.session


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)
