module Page.Settings exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api exposing (Cred)
import Api.Endpoint as Endpoint
import Avatar
import Browser.Navigation as Nav
import Email exposing (Email)
import Html exposing (..)
import Html.Attributes exposing (..)
import Route
import Session exposing (Session)

type alias Model =
    { 
         session : Session
    }



type Msg
    = GotSession Session


init : Session -> ( Model, Cmd Msg )
init session =
      let
          _ = Debug.log "init" "function" 
          md = 
            {
             session = session
            }
       in
       ( md , Cmd.batch
           [ 
           ]
       )



view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Sell Cryptocurrencies"
    , content =
              div [class "container"]
              [
                h2[][text "Cookies policy of the website www.greek-coin.com"]
              , h3[][text "Data Processing"]
              , h4[style "text-decoration" "underline"][text "Contact"]
              , p[][text "If you contact us through the form on the website or by email, your details will be stored for six months to process the request and in case of subsequent questions. We will not share this information without your consent. If you fill out the contact form, greek-coin.com, as a processor, processes the data based on the General Terms and Conditions."]
              , h4[style "text-decoration" "underline"][text "Purposes of analysis"]
              , p[][text "Inaddition, the data are collected and used for analysis purposes.This data processing is not personal (see below for information about cookies)."]
              , h4[style "text-decoration" "underline"][text "Computer security"]
              , p[][text "When visiting this site, logs that contain the IP address and other data to access the site (such as date, time, user, analyzer) are also stored. Data processing is limited in time (maximum seven days) and only to protect against DDOS attacks or other interference with site functionality and any underlying database systems."]
              , h3[][text "Legal basis for data processing"]
              , ul[]
                [
                    li[][text "The site processes the data exclusively on the basis of legal provisions (GDPR, TKG 2003)"]
                  , li[][text "Data processing is based on the article. 6 paragraph 1 lit. (b) (performance of the contract) GDPR and § 96 (3) TKG."]
                  , li[][text "When using analysis tools, data is used based on the article. 6 paragraph 1 lit. (f) (legitimate interest) GDPR. The legitimate interest in using the data is to improve the website and the success of online advertising."]
                  , li[][text "The use of data security measures also takes place on the basis of the article. 6 paragraph 1 lit. (f) (legitimate interest) GDPR. The legitimate interest in data usage is the protection of your computer systems."]
                ]
              , h2[][text "About cookies"]
              , h3[][text "What are cookies?"]
              , p[][text "This site uses so-called cookies. These are small text files stored on your device using the browser. They are harmless."]
              , p[][text "This website uses session cookies. These are created when the site is dialed and automatically deleted. They're used for identificationif you come back to the same site again in a short period of time to take back the pre-selected preferences. Personal data are not stored or processed."]
              , p[][text "Cookies are designed to make the site very user-friendly. Some cookies remain stored on your device until you delete them. They allow the site’s administrator to recognize the browser you are using the next time you visit. If you do not want this, you can set up your browser to let you know how to set cookies and allow it only in individual cases. However, disabling cookies may limit the functionality of the site."]
              , p[][text "Technical cookies and cookies serving aggregate statistical purposes"]
              , p[][text "Necessary activity for the function of the Service. This site uses Cookies to store the user's session and perform other activities that are absolutely necessary for the operation of this site, for example activities related to traffic distribution."]
              , p[][span[style "text-decoration" "underline"][text "Activity on saving preferences, optimization, andstatistics"], br[][], text " This site uses cookies to store your browsing preferences and to optimize the user's browsing experience. These cookies include, for example, those used to determine language and currency preferences, or to manage statistics used directly by the site’s owner."]
              , h3[][text"Other types of cookies or third parties installing cookies"]
              , p[][text"Some of the following services collect statistics in anonymous and aggregate form and may not require the User's consent or may be handled directly by the Owner - as described - without the help of third parties"]
              , p[][text "Some of the following services collect statistics in anonymous and aggregate form and may not require the User's consent or may be handled directly by the Owner - as described - without the help of third parties"]
              , h3[][text  "How to provide or with draw your consent to install cookies"]
              , p[][text "In addition to what is defined in this document, the user can manage cookie preferences directly from their own browser and prevent - for example - cookies installed bythird parties. Through browser preferences, it is also possible to delete cookies that have been previously installed, including cookies that may have saved the initial consent to install cookies from this site."]
              , p[] 
                [text "Users can for example find information on how to manage cookies in the most commonly used browsers at the following addresses:"
                , ul[]
                  [
                    li[][a[href "https://support.google.com/chrome/answer/95647?hl=el", title "Chrome"][text "Chrome"]]
                  , li[][a[href "https://support.apple.com/kb/Ph29214?locale=en_US&viewlocale=el_GR", title "Safari"][text "Safari"]]
                  , li[][a[href "https://support.mozilla.org/en-US/kb/how-do-i-turn-do-not-track-feature", title "Firefox"][text "Firefox"]]
                  , li[][a[href "https://support.microsoft.com/en-us/help/17442/windows-internet-explorer-delete-manage-cookies#ie=ie-11"][text "I.E"]]
                   ]   
                ]
              ,p[][text "As far as third-party cookies are concerned, users can manage their preferences and withdraw their consent by clicking on the relevant exception link (if provided) by using the third-party privacy policy or by contacting third parties. Such initiatives allow users to choose tracking preferences for most of the advertising tools. The owner therefore recommends Users to use these resources in addition to the information provided in this document."]
              , h3[][text "Which cookies are used on our website and what information is collected?"]
              , p[][text "The website www.greek-coin.com uses cookies for various purposes depending on their function:"]
              , p[][ text "This site uses features of the Google Analytics web analytics service. The provider is Google Inc., 1600 Amphitheater Parkway Mountain View, CA 94043, USA. Google uses the data collected to monitor and review the use of this site, to report on its activities and to share it with other Google services.Google may use the data collected to customize ads on its own advertising network. Google, on behalf of the operator of this site, will use this information to evaluate the use of the site for reporting site activity to measure the performance of online advertising for analysis and optimization purposes. <strong> However, the site administrator does not receive any personally identifiable information."]
              , p[][text 
              """
              The processed data include, in particular, email identifiers (including cookies), internet protocol addresses, device IDs, location data, customer IDs, and user data (especially the time and duration access, etc.) For more information on how to handle user data in Google Analytics, please refer to the Google Privacy Policy available at https://policies.google.com/privacy?hl=en"""
              ]
             , p[][text 
             """
             You may prevent Google from collecting the data generated by the cookie and the use of the site and processing this data from Google by uploading and installing the browser plug-in available under the following link: https://tools.google.com/dlpage/gaoptout?hl=en
             """]
             , p[][text """The relationship with the web analytics provider is based on the processing of command data when using Google Analytics. The data transmission to the processor is based on a European Commission decision (Personal Data Protection). Data is erased regularly (currently every 26 months)."]
             , p[][text "This site uses the Google AdWords advertising program and Google AdWords Conversion Tracking. Google Conversion Tracking is an analysis service provided by Google Inc. (1600 Amphitheater Parkway, Mountain View, CA 94043, USA "Google"). When you click on an ad that is displayed by Google, a conversion tracking cookie will be placed on your machine. These cookies lose their validity after a maximum of 90 days. If you visit certain websites on our site and the cookie has not expired, Google and the site administrator may recognize that you clicked on the ad and redirected to this page. The information collected using the conversion cookie is used to create conversion statistics.Here, the site administrator learns the total number of users who have clicked on an ad and redirected to a page labeled with a conversion tracking tag and / or has taken various actions on the page. However, the site administrator does not receive any personally identifiable information.If you do not want to participate in the tracking, you can oppose this use by preventing cookies from being set up with a corresponding browser software setting (Disable option). They will not be included in conversion tracking statistics. For more information and Google privacy policy, visit: google ads, google privacy """]
             , p[][text "he relationship with your web analytics provider is based on the processing of order data when you use Google Adwords Conversion Tracking. Transmitting data to the processor is based on a European Commission Competence Decision (Self-Confidentiality Security). Google should also erase the data on a regular basis (currently every 39 months)."]
             ,p [][text "This type of service allows interaction with social networks or other external platforms directly from the pages of this site. Interaction and information obtained through this Site are always subject to the User privacy settings for each social network. This type of service may still collect traffic data processing cookies for pages where the service is installed, even when users do not use it"]
             ,h5[][text "social widgets (Facebook, Inc)"]
             ,p[][text "The Like button and social widgets are services that allow interaction with the Facebook social network provided by Facebook, Inc. Personal data is collected: Cookies and User Data. Place of processing: United States - Privacy Policy. Privacy protection."]
             ,h5[][text "Twitter Twitter button and social widgets (Twitter, Inc.)"]
             ,p[][text "The Twitter button and social widgets are services that allow interaction with Twitter's social network provided by Twitter, Inc. Personal data is collected: Cookies and User Data. Place of processing: United States - Privacy Policy. Privacy protection."]
             ,p[][text "This type of service allows this Website and its affiliates to update, optimize, and serve the advertisement based on the prior use of the Site by the User. This activity is performed by tracking usage data and using cookies, information passed to partners managing remarketing and behavior. In addition to any exception offered by any of the following services, the User may opt out of using third-party cookies by going to the Network Advertising Initiative opt-out page."]
             ,h5[][text "Facebook's custom audience(Facebook, Inc.)"]
             ,p[][text "Facebook's custom audience is a remarketing and behavior service provided by Facebook, Inc. linking the activity of this web page to the Facebook advertising network. Collection of personal data: Cookies and email address. Place of processing: United States - Privacy Policy - Exception. Privacy protection."]
             ,h5[][text "Remarketing on Facebook (Facebook, Inc.)"]
             ,p[][text "Remarketing on Facebook is a remarketing and behavior service provided by Facebook, Inc. that links the activity of this Website to the Facebook advertising network. Personal data is collected: Cookies and User Data. Place of processing: United States - Privacy Policy - Exception. Protection participation"]
             ,h3[][text "How to check cookies?"]
             ,p[][text "Cookies are stored on your computer or device after you learn about your privacy settings and give your consent for each of these categories, with the exception of Basic Cookies, Cookies, and Trafficdata processing Cookies for which explicit consent is not required. It is at your discretion to oppose the use of cookies on your computer or device, check and / or delete cookies."]
             ,p[][text "You can delete cookies from your computer or device at any time by following the instructions outlined in the following links:"]
             ,ul[]
               [
                   li[][a [href "https://support.google.com/chrome/answer/95647?hl=el"][text "Chrome"] ]
               ,   li[][a [href "https://support.apple.com/kb/Ph29214?locale=en_US&viewlocale=el_GR"][text "Safari"]]
               ,   li[][a [href "https://support.mozilla.org/en-US/kb/how-do-i-turn-do-not-track-feature"][text "Firefox"]]
               ,   li[][a [href "https://support.microsoft.com/en-us/help/17442/windows-internet-explorer-delete-manage-cookies#ie=ie-11"][text "Internet Explorer"]]
               ]
             ,p[][text "In this way, you withdraw your consent to the use of cookies on your computer or device."]
             ,p[][text "You can also set up the browser you use in such a way that it either alerts you to the use of cookies on specific web site services, or does not allow the acceptance of cookies in any way."]
             ,h3[][text "What are your rights?"]
             ,p[][text "You have the right to request, access, correct, and fill in your personal information at any time. Information about the protection of your personal data and about your rights can be found in the Privacy Policy here (link). Specifically, with regard to cookies, you have the right to delete them, restrict their processing to use some or all of the cookies and thus to process your data."]
             ,h3[][text "Where can you find more information on general cookie usage?"]
             ,p[][text "More information on the general use of cookies, as well as their exclusion or restriction methods, can be found"]
             ,a[href "http://cookiepedia.co.uk/"] [text "cookiepedia.co.uk"]
             ,p[][text "and"]
             ,a[href "http://www.allaboutcookies.org/"][text "http://www.allaboutcookies.org/"]
             ,h3[][text "Changes incookie’s Policy."]
             ,p[][text "This policy will be updated in accordance with the applicable regulatory framework. We encourage you to read this Policy regularlyto know how your Data is protected."]
             ,h4[][text "Content appearance from external platforms"]
             ,p[][text "This type of service allows you to view content hosted on external platforms directly from the pages of this Website and interact with them. This type of service may still collect web traffic data for the pages where the service is installed, even when users do not use it."]
             ,h4[][text"Content appearance from external platforms"]
             ,p[][text "This type of service allows the owner to create user profiles starting from an email address, a personal name, or other information provided by the user on this site, as well as monitoring user activities through analysis functions.These Personal Data may also be combined with publicly available User Information (such as Social Profiles) and used to build private profiles that the Owner may display and use to improve this Site. Some of these services may also allow you to send messages to the user, such as emails based on specific actions running on this site."]
             ,h5[][text "Your rights"]
             ,p[][text "You have the right to update, correct, delete, limit processing, data transfer, revocation, and response. If you believe that your data processing violates the data protection law, or if your data protection claims have been violated in some way, you can make complaints to the supervisor. In Austria, this is the data protection authority."]
             ,h4[][text "Definitions and legal references"]
             ,p[][text """
             <i><strong>Personal data (or data)</strong></i><br>Any information that directly, indirectly or in relation to other information - including a personal identification number - allows the identification or identificationof a natural person."""]
             ,p[][text """
<i><strong>Usage data </strong></i><br>Information collected automatically through this Site (or third party services used on this Site), which may include: the IP addresses or domain names of the computers used by the Users using this Website, the URIs ( Uniform Resource Identifier), at the time of the request, the method used to submit the request to the server,the size of the file received in response, the numeric code indicating the status of the server response (successful outcome, error, etc.), the source country, the browser and operating system functions used by the User, the various time-per-visit details (e.g., time spent on each page of the Application), and details of the route followed in the Application with special reference to the sequence, the pages you have visited, and other Measures relating to the operating system of the device and / or the user's IT environment."""]
              ,p[][text "<i><strong>Data subject</strong></i><br>The person who uses this Site and which, unless otherwise specified, coincides with the Underlying Data."]
              ,p[][text "<i><strong>Data processor (or data controller)</strong></i><br>The individualor legal person, public authority, organization or other entity processing personal data on behalf of the auditor as described in this privacy policy."]
              ,p[][text """<i><strong>Data controller (or owner)</strong></i><br>An individualor legal person, a public authority, an organization or other entity which, either alone or together with others, determines the purposes and means of processing the Personal Data, including security measures relating to its operation and use Website. The Data Controller, unless otherwise specified, is the owner of this Site."""]
              ,p[][text """<i><strong>This site (or this app)</strong></i><br>The means by which the User's Personal Data is collected and processed."""]
              ,p[][text "<i><strong>Service</strong></i><br>The service provided by this site as described in the relevant terms (if available) and on this site / application."]
              ,p[][text "<i><strong>European Union (or EU)</strong></i><br>Unless otherwise stated, all references made in this document to the European Union include all the current Member States in the European Union and the European Economic Area."]
              ,p[][text "<i><strong>Cookies</strong></i><br>Small sets of data stored on the user's device."]
              ,p[][text "<i><strong>Legal information</strong></i><br>This privacy statement has been prepared on the basis of provisions of many laws.13 / 14 of Regulation (EU) 2016/679 (General Data Protection Regulation). This privacy policy is strictly related to this site."]
 
             

              , h2[][text " A. PROTECTION OF PERSONAL DATA"]
              , p[][text """The person responsible for collecting and processing personal data on the site """, a [href "https://greek-coin.com/"] [text "greek-coin.com"],text """ is "GREEKCOIN OÜ" has been set up and complies with the Laws of the Estonian Republic, with Registration code 14787392, with headquarters in Estonia, Tallinn, Kesklinna linnaosa, Roseni tn 13, 10111, e-mail: info@greek-coin.com, hereafter he is called as the Data Processing and Collection Manager."""]
             , p[][text """User personal data is processed in accordance with Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of individuals with regard to the processing of personal data and the free movement of such data and the repeal of Directive 95/46 / EC ("GDPR") and other applicable data protection provisions supplementing and / or implementing the GDPR."""]
             , text "The person responsible for collecting and processing personal data shall ensure that personal data:"
             , ol[]
               [ 
                    li[][text "Only processed on a legal basis"]
                 ,  li[][text "They have been taken for specific purposes only and are not further processed in a manner incompatible with these purposes."]
                 ,  li[][text "They are sufficient, appropriate, and not excessive"]
                 ,  li[][text "Accurate and recent"]
                 ,  li[][text "They are not kept longer than necessary"]
                 ,  li[][text "Stored safely"]
               ]
             , p[][text "The Data Processing and Data Collection Operator performs user information acquisition and behavior in the following way:"]                                            , ol[]
               [ 
                   li[][text "With data voluntarily sent by users to an email or a fill-in form on greek-coin.gr"]
                ,  li[][text "With data voluntarily provided by users necessary for transactions in Bitcoins or other cryptocurrencies."]
                ,  li[][text "Storing cookies on terminal devices. Read here about privacy policy."]
               ]
             , p[][text "The site may contain links to other websites maintained by third parties who have their own privacy policies. Before providing any personal data to such sites, read carefully the applicable rules and privacy policy. Keep in mind that depending on the payment method you choose, you may be asked to agree to different privacy policies. The person responsible for collecting and processing personal data is not responsible for the ways of collecting, storing and protecting your personal data from third parties."]
            , p[][text "The person responsible for collecting and processing personal data processes the personal data in order to correctly create and execute the services provided electronically, in particular to finalize Bitcoins market transactions and other provided encryption by users."]
            ,p[][text "Collection and processing of personal data by users by the person responsible for the collection and processing of personal data becomes necessary under a legal basis. Read our <a href='/Page/56/Custom Validation Policy'> Here </a> for Know Your Customer KYC vs. AML & Anti-Terror Finance Funding (CTF) )"]
            ,p[][text "The person responsible for the collection and processing of personal data is processing personal data and for detecting and preventing fraud or other crime, so the person responsible for collecting and processing personal data adopts the GDPR policy to ensure document security CERTIFICATION AND VERIFICATION POLICY Know Your Customer KYC Against Money Laundering (AML) & Anti-Terrorist Funding (CTF)."]
            ,p[][text "The person responsible for collecting and processing personal data processes the following personal data:"]
            ,ol[]
            [
                li[][text "Name and Surname"]
            ,   li[][text "Email, email address"]
            ,   li[][text "IP Address"]
            ,   li[][text "Bitcoin Address or other encrypted passwords"]
            ,   li[][text "Gender"]
            ,   li[][text "Date of Birth"]
            ,   li[][text "Place of residence, country, city, street and number, postal code"]
            ,   li[][text "Photo of user with necessary documents"]
            ,   li[][text "Photo or copy of an identity document, passport, and document proving an address"]
            ]
           , p[][text "In addition, when the greek-coin.gr user contacts the person responsible for collecting and processing personal data by telephone, e-mail, mail or when the user communicates with the person responsible for collecting and processing personal data through social networks or when the user the person responsible for the collection and processing of personal data communicates with the user about the activities or services provided by the person responsible for the collection and processing of personal data, the person responsible for the collection and processing of personal data"]
           ,p[][text "The Data Collection and Processing Authority processes personal data for market research purposes, behavioral research, and user preferences to improve the quality of service provided by the person responsible for collecting and processing personal data."]
           ,p[][text "The person responsible for the collection and processing of personal data processes information voluntarily provided by the user necessary for the provision of services and the detection / prevention of fraud or other crime. The site https://greek-coin.gr can also store information about connection parameters (time stamp, IP address). Data in forms is not disclosed to third parties except with the user's consent. "]
          ,p[][text "The data provided in the forms of completion or communication are processed for the purpose resulting from the use of the services of the site https://greek-coin.gr such as the Bitcoins or other concealed copies. The data provided in the forms may be provided to entities that perform technically certain services - in particular, the transfer of information about the registered domain owner to entities operating as web domains, payment service websites or other entities with which the collector collects and processing of personal data."]
          ,p[][text "The user also has the right to ask the person responsible for collecting and processing personal data to immediately delete the personal data concerning him / her. The person responsible for collecting and processing personal data is required to delete personal data without undue delay if:"]
          ,ol[]
            [
                li[][text"Personal data is no longer necessary for the purposes for which it was collected or otherwise processed "]
             ,  li[][text"User consent based on data processing is retired"]
             ,  li[][text"Personal data submitted without legal processing"]
             ,  li[][text"Personal data must be removed to comply with the legal obligation"]
            ]
          ,p[][text "The user whose data are processed for direct marketing has the right to oppose at any time the processing of personal data concerning him / her for the purposes of such marketing, including the profile, to the extent that the processing relates to such direct marketing."]
          ,p[][text "The data user has the right to receive in a structured, common and used machine-readable form his personal data provided to the person responsible for the collection and processing of personal data and has the right to send the personal data to another person responsible for collecting and processing of personal data without interfering with the person responsible for collecting and processing personal data."]
          ,p[][text "The user has the right to file a complaint with the data protection officer about how the data collection and processing processor processes the user's personal data."]
          , p[][text "Contact details of the supervisory authority:"]
          , p[][text "Your data will be retained for as long as necessary for the purpose for which it was collected or for as long as required by contract or under applicable law."]
          , p[][text "We take reasonable physical and technical means to protect the data we collect through the Site. However, keep in mind any web site, no internet transmission, no computer system and no wireless connection is absolutely safe."]
          ,p[][text "Part of the content, ads, and / or features of the Site may be provided by third parties not affiliated with the Company, such as advertisers. The Site also includes links to other sites under the responsibility of third parties. The Company is not responsible for the terms of protection of personal data applied by such third parties."]
          ,p[][text "We may use cookies, beacons and / or other technologies in certain parts of our Site. Cookies are small files that store information on the user's hard disk in terms of using specific services and / or pages of the Site. Cookies serve many useful purposes, such as making it easier for users to access specific services or pages for statistical purposes to determine which services or parts of the Web site are most popular and to see which pages and which functions users are visiting and how much time they spend on them, to provide custom content or ads, etc. You can set up your browser to accept all cookies, reject Go to & laquo; Help & raquo; of the browser you are using to learn how to change your cookie preferences. In the event that the user does not wish to use cookies for his / her recognition he / she may not have further access to the services and / or functions of the Site based on them."]
          ,br[][]
          ,br[][]
          ,br[][]
          , h2[][text "B. ABOUT COOKIES"]
          , p[][text "This site uses so-called cookies. These are small text files stored on your device using the browser. They do not hurt."]
          , p[][text "This page uses so-called session cookies. These are created when the site is automatically dialed and deleted. They're used for recognition if we come back to the same site again in a short period of time to take back the pre-selected preferences. Personal data is not stored or processed."]
          , p[][text "Cookies are designed to make the site very user-friendly. Some cookies remain stored on your device until you delete them. Allow the site administrator to recognize the browser you are using the next time you visit. If you do not want this, you can set up your browser to let you know how to set cookies and allow it only in individual cases. However, disabling cookies may limit the functionality of the site."]
          , h3[][text "Technical cookies and cookies serving aggregate statistical purposes"]
          , h5[style "text-decoration" "underline"][text"Preferences, optimization, and statistics saving activity"]
          , p[][text "This site uses cookies to store your browsing preferences and to optimize the user's browsing experience. These cookies include, for example, those used to determine language and currency preferences, or to manage statistics used directly by the Site Owner."]
          , h3[][text "Other types of cookies or third parties installing cookies"]
          ,p[][text "Some of the following services collect statistics in anonymous and aggregate form and may not require the consent of the User or may be managed directly by the Owner - as described - without the help of third parties."]
          ,p[][text "If third-party services are included in the following tools, they can be used to track users' browsing habits - beyond the information specified herein and without the knowledge of the Holder. For detailed information, please refer to the privacy policy of the listed services. "]
          ,h2[][text "C. GENERAL"]
          ,p[][text "Any omission or delay in the exercise by the Company of any right or provision of these Terms does not constitute a waiver of the applicable right or provision unless it is acknowledged and agreed in writing by the Company. The terms include the overall agreement between you and the Company and prevail over all prior or contemporaneous negotiations, discussions or agreements, if any, between the parties on the subject contained herein. However, the use of the Site on your behalf is subject to the additional disclaimers and warnings that may appear on the Site."]
          ,p[][text"If any term or condition of the foregoing is found to be unlawful, void or unenforceable, it will be removed, it will be deemed as never registered and under no circumstances will affect the validity, binding and enforceability of the other Terms."]
          ] 
    }




update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
       GotSession session ->
           ({model |session = session}, Cmd.none)


        

-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



toSession : Model -> Session
toSession model =
    model.session
