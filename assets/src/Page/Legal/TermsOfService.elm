module Page.Legal.TermsOfService exposing (..)

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
    { title = "Terms of service"
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
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "Terms of Service"]
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
                    h3[style "font-weight" "bold"][text "Greek Coin OÜ Terms & Conditions of Service"]
                 ,  span[]
                    [
                        text """These Greek Coin OÜ Terms & Conditions are entered into between the User (hereinafter referred to as “User”, “you” or “your”) and Greek Coin OÜ operators (hereinafter “Company”, “us”, “our” and “we”). By accessing or using the services or accepting any Greek Coin OÜ Services provided by Greek Coin OÜ, you agree that you have read, understood and accepted the Terms & Conditions included in these Terms & Conditions as well as our Privacy Policy.
You are required to read the terms that govern the Greek Coin OÜ services and understand them. They contain important provisions that define the rights and the duties of both Greek Coin OÜ and you. These terms include an arbitration provision that requires all claims to be resolved by way of legally binding arbitration. By using the Greek Coin OÜ services and information within, you acknowledge and agree that you are aware of the risks associated with digital currency transactions and the extreme volatile nature. You also acknowledge and agree that Greek Coin OÜ shall not be held liable for such risks or adverse outcomes. You must not access and/or use in any manner the Greek Coin OÜ services and informative material if you do not agree with these terms & conditions. """
                    ]
                 ]
             ]

          ,  div[class "row"]
             [
                 div[class "col"]
                 [

   ol[class " countable "][li[][text """Definitions

These terms shall also apply to all the Website Policies and be understood as follows:

        """
      , ol[class "countable"][li[][text """Greek Coin OÜ P.L.C - a company incorporated under the Estonian Commercial Code, with registration number 14787392 and authorized by the Estonian Financial Supervisory Authority to operate as a Private Limited Company which offers Financial Services, that includes: a) Providing a virtual currency wallet service (Activity License FRK001080), and b) Providing services of exchanging a virtual currency against a fiat currency (Activity license FVR001195).
        """]
          , li[][text """Company Operators – all parties that are being paid by the Company under a contractual agreement of employment to provide an explicit service or services for the Company. Under these terms, the Company’s Operators may proceed with changes in order to comply to business needs and legal requirements, and they shall perform their obligations without any liability, unless they fail to comply with their legal obligations. From time to time the Services provided by the Company and the Operators may be expanded based on new service provisions and business adjustments. By continuing using the Greek Coin OÜ services, you agree to the new terms introduced by the company.
        """]
          , li[][text """Users – all individuals or legal persons that access, download, interact or use the Company’s Services, website or platform.
        """]
          , li[][text """Cryptocurrency - a digital currency which uses encryption techniques to regulate the generation of units of currency and verify the transfer of funds, operating independently of a central bank. “[…] cryptocurrencies are a form of property capable of being the subject of a proprietary injunction.” [2019] EWHC 3556 (Comm), 2020 WL00281550]
        """]
          , li[][text """Property - means assets of any kind, whether corporeal or incorporeal, movable or immovable, tangible or intangible, and legal documents or instruments in any form including electronic or digital, evidencing title to or an interest in such assets.
        """]
          , li[][text """Digital Assets – all digital currencies, their derivatives and other types of digitized assets with a certain value.
        """]
          , li[][text """Account – User’s account including virtual accounts, subaccounts and records with information provided by the User and owner of the account for the opening of that account. An account includes all the information concerning personal data, transactions, asset changes, usage of services and other basic information. This information is stored, managed and protected according to the General Data Protection Regulation (EU) 2016/679.
        """]
          , li[][text """Login Details – data given or determined by the user enabling it to access the Account.
        """]
          , li[][text """Funds – Any asset maintained in a user’s account.
        """]
          , li[][text """Fiat Currency – government issued currency which is not backed by a physical commodity with intrinsic value.
        """]
          , li[][text """Crypto Trading – transactions in which one digital currency is exchanged for another digital currency.
        """]
          , li[][text """Fiat trading – transactions in which one digital currency in exchanged with fit currency or vice versa.
        """]
          , li[][text """AML / CFT risk assessment – internal process of the company to reassure that it complies with AML / CFT regulations. It is the evaluation of transactions, accounts, accounts’ activities and other parameters that define the account’s risk of money laundering, terrorism financing and other illegal activities.
        """]
          , li[][text """RTO – refers to Receive and Transfer of Orders that is the procedure facilitated for the execution of a client’s trading request. It is acknowledged that the order might not be executed at the current price of the request but on the price of the time of realization of the order and the closing of the position.

     """] ] ]
    , li[class "countable"][text """Declarations & Basic Information

        """
      , ol[class "countable"][li[][text """The Users must protect their internet connection and computer from threats that every internet user may face by using antivirus programs and their most updated versions. There is a possibility of infecting the IT system and cause damage through viruses, worms, trojans, etc. The Company also informs that particular threats related to the use of electronic services, including those described in these Terms & Conditions, are related to the activities of hackers, aimed at breaking into both the Company’s system (e.g. attacks on its website) and the User’s system. The User acknowledges, therefore, that despite the Company’s use of various modern protection technologies, there is no perfect protection against the abovementioned undesirable actions and the Company shall not be held liable for material changes of a user’s account realized outside the powers of control of the Company and/or its Operators and/or third parties.
        """]
          , li[][text """The User understands and acknowledges that the Company does not in any manner contain information on the website that constitute a solicitation, recommendation, endorsement, or offer by the Company or any third parties to buy or sell any asset, Cryptocurrency or other financial instruments. The User also acknowledges that the company’s affiliates do not provide any investment recommendation in connection with the Website’s operation, nor do they give any advice or offer or any opinion with respect to the suitability, profitability or appropriateness regarding any investment, property or Cryptocurrency. User is responsible for determining whether an investment strategy is suitable for him. All transactions will be recorded and initiated by a User either through the platform or through the phone from the operators by following a certain procedure that provides with more security and safety of the transactions and the RTO.
        """]
          , li[][text """The User should consult with an attorney, financial advisor, or other investment professional to determine what may be best for his or her individual needs. The Company does not make any guarantee or other promises as to any results that may be obtained from using its content. The company provides a tool for you to facilitate any exchange you wish with your own risk.
        """]
          , li[][text """To the maximum extent permitted by law, the Company disclaims any and all liabilities in the event any information, commentary, analysis, opinion and/or recommendation prove to be inaccurate, incomplete or unreliable or result in any investment or other losses since the user has agreed that he/she has facilitated proper review of such informative quote and has ordered the proceeding of such action at his/her own risk. In general, the User’s use of the information on the Website or materials linked from the Website is at his or her own risk and we strongly advise you to give special attention to the volatile characteristics of the market, the regulatory updates and all the information provided by us or other websites, since most of the articles on that industry are not verified for the truthfulness and accurateness of the information provided and it is very difficult sometimes to distinguish an informative from a provocative article. Please, proceed with care and common sense.
        """]
          , li[][text """All agreements entered into separately between you and the Company are deemed supplementary terms that are an integral part of these terms and shall have the same legal effect. If you accept to use the website and the information therein, you accept these terms and conditions.
        """]
          , li[][text """The Services provided by the Company consist of Providing a virtual currency wallet service, and services of exchanging a virtual currency against a fiat currency. The Company shall not be held liable for any other service, aid or accommodation made by its Operators.
        """]
          , li[][text """The Company is entitled to introduce changes in technical and technological requirements necessary to use the Website by providing information about these changes to the User’s e-mail address which was provided during the registration of the Account. A change in technical or technological requirements does not constitute a change of the Terms & Conditions unless it consists a material change of the rights and obligations of the parties.
        """]
          , li[][text """Services are provided for a fee. Fees and commissions binding the User shall apply to a given activity on the day of its performance according to the Fee Table.
        """]
          , li[][text """Charging fees and commissions for the Services provided take place automatically at the moment of ordering the Transaction from funds dedicated by the User to execute the Transaction.
        """]
          , li[][text """The User presents and warrants that the user has not been included or does not come under any trade embargoes or economic sanctions list, by accessing, using or accepting the Services. The Company reserves the right to deny the conduct of business to such individuals or legal persons or restrict in its discretion the provision of services in certain countries or regions in compliance to the Company’s Policies.

     """] ] ]
    , li[class "countable"][text """Conditions for the provision of Services

        """
      , ol[class "countable"][li[][text """One of the conditions enabling the use of the Services by the User is to set up an account on the Website – for this purpose, the User is obliged, among others, to:
            """
      , ol[class "countable"][li[][text """give an e-mail address to which it has exclusive access;
            """]
          , li[][text """a password of its choice (known only to the User) meeting requirements of the Website;
            """]
          , li[][text """READ AND ACCEPT the Terms & Conditions, Privacy Policy, table of fees or other documents if their acceptance is required by the Company;
            """]
          , li[][text """complete other technical activities and give additional data required by the Company.
         """] ] ]
          , li[][text """In the case of Accounts created for entities other than natural persons, the User must be entitled to represent them. In that case, the User provides its own data, the personal data of the management board of that entity and its actual beneficiaries. More information for the Client Acceptance Policy can be requested from the Operators.
        """]
          , li[][text """Specific technical requirements to set up an Account, as well as required information and documentation, may be subject to changes and be different for other Users depending on AML / CTF risk assessment.
        """]
          , li[][text """The User is obliged to provide real, current and complete data required by the Company. The User is responsible for the consequences of providing incorrect, outdated or incomplete data.
        """]
          , li[][text """The Company may refuse to register an Account for the User when:
            """
      , ol[class "countable"][li[][text """User is a citizen, resident or from a country where, according to the information published on Website, due to legal restrictions and AML / CTF risk assessment, Services are not provided by the Company;
            """]
          , li[][text """Registration is attempted or made using software preventing determination of a country from which it is made (VPN);
            """]
          , li[][text """Data given by the user has been used before for creating another Account;
            """]
          , li[][text """It is recommended by AML / CTF risk assessment.
         """] ] ]
          , li[][text """The Service Contract is concluded upon completion of the Account registration process.
        """]
          , li[][text """The User can open, have and use only one Account on the Website.
        """]
          , li[][text """Upon completion of the Account registration process, the User may log in to the Service, but may not initiate any order. In order to undertake the activities described above, the User must verify the Account.
        """]
          , li[][text """During the verification process, the User may be obliged to complete the procedure of verification of the identity and authenticity of the data he provided, performed by a professional third party, with procedures implemented by such entity.
        """]
          , li[][text """The Company may demand to submit additional documentation, information or explanation, as well as refuse to verify the User due to the insufficient credibility, incompleteness of the data or documents provided by the User or due to the results of the company’s AML / CFT risk assessment.
        """]
          , li[][text """The duration of the procedure for verification of the identity and authenticity of the data provided as well as the duration of the AML / CTF risk assessment depends on the current capabilities of the Company and of third parties, therefore the Company does not guarantee and is not responsible for the duration of such activities.
        """]
          , li[][text """The User acknowledges that the Company does not guarantee the User any profit in connection with the use of the Website.
        """]
          , li[][text """The User agrees not to perform any actions through the Website that violate the provisions of these Regulations, guidelines published on the Website, the Website’s policies, legal provisions or basic principles of a honesty, fairness and morality.
        """]
          , li[][text """The User agrees to use the Website solely for its own personal use, in its own name and on its own behalf and not in favor of other parties.
        """]
          , li[][text """The User agrees to use the Website in a good faith, in particular, to immediately notify the Company of any errors observed in the Website software and to refrain from using any errors observed in the Website software to the detriment of the Company or other Users. Transactions executed in breach of this section shall be cancelled or revoked and the User shall not be entitled to any claims, and the User shall be held liable for any losses and damages of the Company in violation of this provision.
        """]
          , li[][text """The Company indicates that it can, at any time, at its sole discretion, perform AML / CTF risk assessment of the user, and user’s behaviors or transactions.
        """]
          , li[][text """The User agrees to provide all information, materials and documents that the Company will require from it in connection with the AML / CTF risk assessment. In case of a breach of this obligation, the Company shall be entitled to refuse to execute or to suspend the execution of the Transaction as well as to stop deposits and withdrawals of Funds and Cryptocurrencies.
        """]
          , li[][text """The Company has the right to refuse to open an Account or process a transaction or continue the operation of the Account if the User complaints and doesn’t cooperate and doesn’t follows the procedures of the Company, and such a behavior shall be considered to be in bad faith and with purposes other than the resolution of the issue that has arisen and may be considered as an obstruction of the Company’s operation.
        """]
          , li[][text """The Company has the right to refuse to process the User’s transaction as well as to freeze User’s deposits and withdrawals, in response to a request of state authorities or in order to enforce the transaction limits established and published on the Website.
        """]
          , li[][text """The Company reserves the right to refuse to make or withdraw from any purchase, sale or exchange at its own discretion, even after the funds have been withdrawn from the User’s account in the following situations:
            """
      , ol[class "countable"][li[][text """when the Provider suspects that the Transaction may (or may be likely to) involve money laundering, terrorist financing, fraud or any other criminal offence;
            """]
          , li[][text """in response to a subpoena or other order from State institutions or competent authorities;
            """]
          , li[][text """if the Company reasonably suspects that the transaction is the result of an error;
            """]
          , li[][text """if the Company suspects that the Transaction is made in breach of the Regulations or other terms and conditions regulating the use of the Services, published on the Website
            """]
          , li[][text """when the Transaction is made by a resident of a country from a current list of countries with prohibited access to the Services published on the Website.
         """] ] ]
          , li[][text """In such cases, the Company shall not be obliged to reinstate the Transaction at the same price or under the same terms and conditions as the cancelled Transaction.
        """]
          , li[][text """The Company reserves the right to monitor, review, retain or disclose to authorized entities any information necessary to comply with applicable legal provisions, including in particular the prevention of money laundering and terrorist financing.
        """]
          , li[][text """The User is obliged to inform Company about any changes of data provided to the Company within 3 months since the change has occurred.
        """]
          , li[][text """The Company has the right to perform periodical User’s data verification, in particular by requesting him to submit documentation, explanation and information. If the User does not satisfy the Company’s request, the Company shall be entitled to refuse to execute or freeze the transaction as well as to stop deposits and withdrawals of Funds and Cryptocurrencies.
        """]
          , li[][text """The User has access to the provided information, which can be altered manually at any time.

     """] ] ]
    , li[class "countable"][text """Registration and Requirements

        """
      , ol[class "countable"][li[][text """The person wishing to register shall provide with a valid e-mail and a password. After the confirmation of the e-mail through the given e-mail, the person becomes a holder of an account as a user.
        """]
          , li[][text """For the user to proceed with any transaction, the user must go through some verifications stages by providing a valid ID, with his/her name, surname, telephone number, vat number, taxation authority and any updated utility bill (3 months) that verifies for the name and the address of the user.
        """]
          , li[][text """The ID verification must contain three pictures. One photograph of the front of the ID, a “selfie” with the front of the ID and a photograph of the back of the ID.
        """]
          , li[][text """For further information concerning the procedure of accepting a user, the user can ask for the Client Acceptance Policy.

     """] ] ]
    , li[class "countable"][text """Transactions

        """
      , ol[class "countable"][li[][text """Transaction execution is possible for a User who:
            """
      , ol[class "countable"][li[][text """has registered and holds a verified Account on the Website, and the Transaction is within the limits of his economic profile;
            """]
          , li[][text """made a deposit of Cryptocurrencies or Funds in accordance with the instructions available on the Website;
            """]
          , li[][text """submitted an instruction to execute a Transaction;
            """]
          , li[][text """the performed assessment of the risk of AML / CTF does not indicate any contraindications to the implementation of the Transaction.
         """] ] ]
          , li[][text """The instruction to execute a Transaction shall be submitted through specifying all required parameters of the Transaction, such as, in particular, the price and quantity of the Cryptocurrency to be acquired or sold.
        """]
          , li[][text """Submitting an instruction to execute Transaction blocks the User’s funds in an appropriate amount.
        """]
          , li[][text """The Company may limit the possibility of executing a Transaction by introducing or modifying the minimum or maximum amounts of Transactions for particular Funds or Cryptocurrencies.
        """]
          , li[][text """Under no circumstances shall a Transaction (including the fee) be executed in excess of the value of funds held.
        """]
          , li[][text """Execution of a Transaction is final. User cannot demand to return Cryptocurrencies or Funds, which were purchased using the Website.
        """]
          , li[][text """The order for a transaction is initiated by the user and is transferred automatically to the broker.
        """]
          , li[][text """If the user does not wish to use the platform for his/her transaction, Greek Coin OÜ can be instructed to execute the order in place of the user through a recorded phone call which will verify the User. In this case, the Company will verify the transaction via the phone provided in the account information. The transaction and the record of personal data are provided only for the execution of the transaction according to the principles of GDPR and the competent Capital Market Commission regulations and will be kept saved for a period of up to 5 years after the termination of the account.
        """]
          , li[][text """Upon completion of the registration and identity verification for your Account, you may conduct Crypto-to-crypto, fiat-to-crypto and vice versa trading in accordance with the provisions of these Terms and Greek Coin OÜ Platform Rules.
        """]
          , li[][text """Upon sending an instruction of using Greek Coin OÜ Services for Crypto-to-crypto Trading, your account will be immediately updated to reflect the open Orders, and your Orders will be included in company’s order book to match other users’ Orders. Once the Transaction is executed, your account will be updated to reflect that the Order has been fully executed and closed. To conclude a Transaction, you authorize Greek Coin OÜ to temporarily control the Digital Currencies involved in your Transaction.
        """]
          , li[][text """If your account does not have sufficient amount of Digital Currencies to execute an Order, Greek Coin OÜ will cancel the entire Order.
        """]
          , li[][text """You agree to pay Greek Coin OÜ the fees specified in the fees table. Any updated fees will apply to any sales or other Transactions that occur following the effective date of the updated fees. You authorize Greek Coin OÜ to deduct from your account any applicable fees that you owe under these Terms.

     """] ] ]
    , li[class "countable"][text """Deposits and Withdrawals of funds and digital assets

        """
      , ol[class "countable"][li[][text """The User may order the withdrawal of Funds or Cryptocurrencies available on the Account at any time.
        """]
          , li[][text """The time between ordering the withdrawal, withdrawing Cryptocurrency or Funds and time of the entry on the Website’s Account or withdrawal on the bank account or User’s addresses, depends on the kind of Cryptocurrency or Funds and is not up to the Company. The Company however shall facilitate a prompt check for the details of the account and thus the withdrawal may take up to a few days, if that is necessary.
        """]
          , li[][text """The minimum and maximum value of deposits, payments and withdrawals of Funds and Cryptocurrencies are specified in the Table of Fees published on the Website, as well as different tiers of User’s verification.
        """]
          , li[][text """The company can amend the minimum and maximum value of deposits, payments and withdrawals due to the change of User’s verification standards or AML / CTF risk assessment.
        """]
          , li[][text """Withdrawals of the Funds and Cryptocurrencies will be implemented only after the User has provided the necessary data required by the Company if the nature, purpose and the AML / CTF risk assessment of the ordered Transaction do not raise any doubt.
        """]
          , li[][text """The Company shall implement the withdrawal of the Funds or Cryptocurrencies to the accounts belonging to and indicated by the User. Information about the owner of the bank account used for withdrawals of Funds has to be identical with those provided to the Company as personal data of User.
        """]
          , li[][text """When the Company returns User’s Funds, it is done to the address (for the Cryptocurrencies) or to the bank account (for Funds) used before by the User, unless User informs about not using such account or address anymore. In case of lack of such bank accounts or addresses, funds shall be stored by the Company until Users provide information about new accounts or addresses.
        """]
          , li[][text """Most of the Digital assets are stored on a cold wallet for maximum security and thus the withdrawal enquiry can be facilitated only during working days and not instantly. However, for better efficiency of the day-to-day transactions, some digital assets will be kept in other liquidity providers or hot wallets.

     """] ] ]
    , li[class "countable"][text """Bonus
        """
      , ol[class "countable"][li[][text """The Company is willing to provide a floating interest rate as a bonus to Trading Accounts that hold their Funds in our exchanger. The Bonus will only be given if the financial statement of the Company declares earnings.
        """]
          , li[][text """The annual interest will be distributed according to the Bonus Table and calculates the average amount kept in the trading account during the previous 12 months according to the clause bellow.
        """]
          , li[][text """The Company will take at consideration the amount kept under the trading account for a month only if these funds are kept in the platform during the whole 30-days period. For example, if the Client keeps x amount of bitcoin in my account for 30 days and one day the client deposits and withdraws 10x of bitcoins then the interest rate will be calculated only for the x amount which was available to the company for consecutive 30 days. The amount of each month shall be calculated according to this clause.
        """]
          , li[][text """The Company may alter this clause and/or terminate such offer at its shole discretion.
        """]
          , li[][text """If the Company is unable to provide such bonus due to Force Majeure circumstances as provided in these terms, the Client shall not be eligible for remuneration from the Company of that bonus.

     """] ] ]
    , li[class "countable"][text """Inactivity Fee
        """
      , ol[class "countable"][li[][text """Greek Coin OÜ reserves the right to apply a fee for dormant or inactive accounts.
        """]
          , li[][text """A client’s trading account is considered inactive when there are less than 2 transactions in a period of 9 months. The fee applied may vary from 0.1% to 0.5% per month after 9 months of inactivity, according to the Trading Account Funds. Activity means any order to the Company to buy, sell or exchange.
        """]
          , li[][text """A client’s trading account is considered dormant when there are no transactions for a period of over 9 months. The fee applied may vary from 0.5% to 1% per month after 9 months of no activity. A client’s trading account may also be considered dormant if the client fails to update the necessary document for KYC/AML requirements. The client’s trading account may also be considered dormant 6 months after the request of an update of the personal information that are necessary for regulatory compliance reasons.
        """]
          , li[][text """If the client holds more than 1 trading accounts, the Company may not apply such inactivity or dormant fees to the other trading accounts if deemed dormant or inactive, only in the case where the trading volume of the active trading account covers the fees of the actual cost of trading account maintenance.
        """]
          , li[][text """The abovementioned fees in section 8.2 and 8.3 may increase over time no more than 10% quarterly.

     """] ] ]
    , li[class "countable"][text """Service Usage Guidelines

        """
      , ol[class "countable"][li[][text """You are prohibited to use the Company’s Services for resale or commercial purposes, including transactions on behalf of other persons or entities. These actions are expressly prohibited and constitute a material violation of these Terms. The content layout, format, function and access rights regarding Greek Coin OÜ Services should be stipulated in the discretion of the Company. Greek Coin OÜ reserves all rights not expressly granted in these Terms. Therefore, you are hereby prohibited from using the Company’s services in any way not expressly authorized by these Terms.
        """]
          , li[][text """These Terms only grant a limited license to access and use the Services. Therefore, you hereby agree that when you use the Services, Greek Coin OÜ does not transfer the Services or the ownership or intellectual property rights of any Greek Coin OÜ intellectual property to you or anyone else. All the text, graphics, user interfaces, visual interface, photos, sounds, process flow diagrams, computer code (including html code), programs, software, products, information and documents, as well as the design, structure, selection, coordination, expression, look and feel, and layout of any content included in the services or provided through Greek Coin OÜ Services, are exclusively owned, controlled and/or licensed by the Company’s Owner and/or operators and/or members, and/or parent companies, and/or licensors or affiliates.
        """]
          , li[][text """The Company owns any feedback, suggestions, ideas, or other information or materials (hereinafter collectively referred to as “Feedback”) about the Company or the Services that you provide through email, or other ways. You hereby transfer all rights, ownership and interests of the Feedback and all related intellectual property rights to the Company. You have no right and hereby waive any request for acknowledgment or compensation based on any Feedback, or any modifications based on any Feedback.
        """]
          , li[][text """When you use our Services, you agree and undertake to comply with the following provisions:
            """
      , ol[class "countable"][li[][text """During the use of the Services, all activities you carry out should comply with the requirements of applicable laws and regulations, these Terms, and various guidelines of Greek Coin OÜ;
            """]
          , li[][text """Your use of our Services should not violate public interests, public morals, or the legitimate interests of others, including any actions that would interfere with, disrupt, negatively affect, or prohibit other Users from using our Services;
            """]
          , li[][text """You agree not to use the services for market manipulation (such as pump and dump schemes, wash trading, self-trading, front running, quote stuffing, and spoofing or layering, regardless of whether prohibited by law or not);
         """] ] ]
          , li[][text """Without written consent from Greek Coin OÜ, the following commercial uses of our data are prohibited:
            """
      , ol[class "countable"][li[][text """Trading services that make use of our quotes or market bulletin board information.
            """]
          , li[][text """Data feeding or streaming services that make use of any market data of Greek Coin OÜ.
            """]
          , li[][text """Any other websites/apps/services that charge for or otherwise profit from (including through advertising or referral fees) market data obtained from Greek Coin OÜ.
         """] ] ]
          , li[][text """Without prior written consent from Greek Coin OÜ, you may not modify, replicate, duplicate, copy, download, store, further transmit, disseminate, transfer, disassemble, broadcast, publish, remove or alter any copyright statement or label, or license, sub-license, sell, mirror, design, rent, lease, private label, grant security interests in the properties or any part of the properties, or create their derivative works or otherwise take advantage of any part of the properties.
        """]
          , li[][text """You may not:
            """
      , ol[class "countable"][li[][text """use any deep linking, web crawlers, bots, spiders or other automatic devices, programs, scripts, algorithms or methods, or any similar or equivalent manual processes to access, obtain, copy or monitor any part of the properties, or replicate or bypass the navigational structure or presentation of our Services in any way, in order to obtain or attempt to obtain any materials, documents or information in any manner not purposely provided through our Services;
            """]
          , li[][text """attempt to access any part or function of the properties without authorization, or connect to our Services or any Greek Coin OÜ servers or any other systems or networks of any of our Services provided through the services by hacking, password mining or any other unlawful or prohibited means;
            """]
          , li[][text """probe, scan or test the vulnerabilities of Greek Coin OÜ Services or any network connected to the properties, or violate any security or authentication measures on Greek Coin OÜ Services or any network connected to Greek Coin OÜ Services;
            """]
          , li[][text """reverse look-up, track or seek to track any information of any other Users or visitors of Greek Coin OÜ Services;
            """]
          , li[][text """take any actions that impose an unreasonable or disproportionately large load on the infrastructure of systems or networks of Greek Coin OÜ Services or Greek Coin OÜ, or the infrastructure of any systems or networks connected to Greek Coin OÜ services;
            """]
          , li[][text """use any devices, software or routine programs to interfere with the normal operation of Greek Coin OÜ Services or any transactions on Greek Coin OÜ Services, or any other person’s use of Greek Coin OÜ Services;
            """]
          , li[][text """forge headers, impersonate, or otherwise manipulate identification, to disguise your identity or the origin of any messages or transmissions you send to Greek Coin OÜ, or
            """]
          , li[][text """use Greek Coin OÜ Services in an illegal way.
         """] ] ]
          , li[][text """By accessing Greek Coin OÜ Services, you agree that we have the right to investigate any violation of these Terms, unilaterally determine whether you have violated these Terms, and take actions under relevant regulations without your consent with prior notice. Examples of such actions include, but are not limited to:
            """
      , ol[class "countable"][li[][text """Blocking and closing order requests;
            """]
          , li[][text """Freezing your account;
            """]
          , li[][text """Reporting the incident to the competent authorities;
            """]
          , li[][text """Publishing the alleged violations and actions that have been taken;
            """]
          , li[][text """Deleting any information that you published which are found to be violations.

      """] ] ]  ] ]
    , li[class "countable"][text """Complaints

        """
      , ol[class "countable"][li[][text """A complaint may be reported by sending an e-mail to the address provided on the Website, via the Website or in writing to the address of our registered office.
        """]
          , li[][text """A complaint shall include:
            """
      , ol[class "countable"][li[][text """data enabling identification and contact with the User
            """]
          , li[][text """a description of the action or omission in question
            """]
          , li[][text """any other information the User considers relevant.
         """] ] ]
          , li[][text """Complaints will be considered on the basis of information provided by the User and shall be considered immediately, but not later than within 30 days from the date of delivery of the complaint to the Company.
        """]
          , li[][text """Within this period, the Company will propose via e-mail or the Website:
            """
      , ol[class "countable"][li[][text """to consider the complaint in the manner requested by the User;
            """]
          , li[][text """to reject the complaint together with the reasons for such a decision;
            """]
          , li[][text """alternative handling of the complaint.
         """] ] ]
          , li[][text """After receiving the proposal specified above, the User has 10 working days to accept or reject the Company’s proposal. Failure to reply within the above deadline shall be deemed a withdrawal of the complaint and it shall be assumed that the Company does not bear any responsibility towards the User in relation to the subject matter of the complaint. Acceptance or rejection of the proposal by the User after the deadline may be treated by the Company as submitted on time.
        """]
          , li[][text """If the User rejects the Company’s proposal within 10 working days, the User is entitled to submit a detailed and reasonable justification for rejection. Failure to state reasons for such rejection within the aforementioned period shall be deemed to constitute a withdrawal of the complaint and it shall be assumed that the Company does not bear any responsibility towards the User in relation to the subject matter of the complaint.
        """]
          , li[][text """No offer under provision 9 shall constitute any acknowledgement by the Company of any misconduct or responsibility related to the subject matter of the complaint. Each acceptance of the offer of handling a complaint shall constitute an acceptance that the complaint will be resolved in a specified manner and an obligation that the User waives all claims resulting from it.
        """]
          , li[][text """Submitting a complaint is a prerequisite for continuing with any legal action.

     """] ] ]
    , li[class "countable"][text """Intellectual Property

        """
      , ol[class "countable"][li[][text """Greek Coin OÜ is a registered trademark.
        """]
          , li[][text """All graphics, animations, texts and other content, including functionality, distribution and location of specific elements used on Website are copyright works protected by law.
        """]
          , li[][text """The User is entitled to use the works within the scope of permitted private use provided by legal provisions.
        """]
          , li[][text """Use beyond the permitted private use requires the prior consent of the Company.

     """] ] ]
    , li[class "countable"][text """Termination

        """
      , ol[class "countable"][li[][text """The Service Contract shall be terminated:
        """]
          , li[][text """upon the User’s request
        """]
          , li[][text """by the Company – by notice in cases specified in the Regulations.
        """]
          , li[][text """The User has the right to withdraw from the Service Contract without giving a reason within 14 days from the date of conclusion of the Contract by submitting a notice of withdrawal. By accepting the Regulations, the User agrees that the use of the Services before the expiry of the above-mentioned term is tantamount to the expiration of the right of withdrawal from the contract
        """]
          , li[][text """In case the Company suspects that the Transaction ordered by the User or any other activity of the User within the Website may be related to committing a crime, money laundering, terrorist financing, violation of the provisions of the Regulations, legal provisions or good morals, the Company is entitled to additional rights:
            """
      , ol[class "countable"][li[][text """the right to terminate the User Account
            """]
          , li[][text """the right to refuse or stop the execution of the Transaction
            """]
          , li[][text """the right to withdraw the Transaction executed
            """]
          , li[][text """the right to perform additional verification of the User by requesting the presentation of relevant documents or information.
         """] ] ]
          , li[][text """The Company is entitled to block the right to execute Transactions and deposit or withdraw of User’s Cryptocurrencies and Cash Funds if:
            """
      , ol[class "countable"][li[][text """legal regulations obliged Company to do so
            """]
          , li[][text """it is justified with AML / CTF risk assessment
            """]
          , li[][text """User has not respected his duty to present additional, unambiguous documentation or information on the demand of Company due to the Regulations
            """]
          , li[][text """User’s country of stay, country of citizenship or country of residence, is on the list of countries excluded from providing Services in accordance with the information published on the Website.
            """]
          , li[][text """Due to the necessity of ensuring safety and the highest quality of the Services provided, the Company is entitled to the following rights:
                """
      , ol[class "countable"][li[][text """the right to suspend the activity of the Website for the time of updating the software or for the time needed to repair the technical failure – if this is possible in a given case, the Company will notify the Users on the Website about the planned technical interruption, sufficiently in advance;
                """]
          , li[][text """the right to discontinue the provision of the Services within a specified geographical area or within all geographical areas;
                """]
          , li[][text """the right to exclude certain types of Transactions from the User;
                """]
          , li[][text """the right to withhold the possibility of registering new Users.
          """] ] ]  ] ]
          , li[][text """The Company may exercise several of the rights specified in this paragraph 6 simultaneously.

     """] ] ]
    , li[class "countable"][text """Liabilities & Disclaimers

        """
      , ol[class "countable"][li[][text """To the maximum extent permitted under applicable law, Greek Coin OÜ disclaims all warranties for their Services and you agree that the Services are provided to the highest efficiency possible and “as is” or “as available” and the Company is not bind by any other oral or written statement or agreement or gesture or practice or standard “doing of business”, but only by the provisions described in the Terms & Conditions with which the User has agreed and undergone a contractual agreement. Thus, Greek Coin OÜ disclaims, any and all other warranties of any kind, whether express or implied, including, without limitation, warranties of merchantability, fitness for a particular purpose, title or non-infringement or warranties arising from course of performance, course of dealing or usage in trade and you waive any such claim against the Company.
        """]
          , li[][text """You acknowledge that the website and the Services may be susceptible to errors, software malwares, 3rd party disfunctions and other inaccuracies concerning the information or statements provided by the Company. Thus, you are being advised to carefully facilitate your own research and reading, and acknowledge that every order to the Company and action in the website is done with your absolute discretion and at your own risk. You further acknowledge that execution, accepting, recording or holding of orders and/or position, cannot be guaranteed.
        """]
          , li[][text """You hereby understand and agree that Greek Coin OÜ will not be liable for any damages or losses arising from or related to:
            """
      , ol[class "countable"][li[][text """Any error, delay, inaccuracy, defect omission, interruption, 3rd party service interruption in the transmission of price data;
            """]
          , li[][text """Any damages incurred by other users’ actions, omissions or violation of these terms, illegal actions of other third parties or any other harmful action or omission made without the prior authorization from Greek Coin OÜ.
         """] ] ]
          , li[][text """To the maximum extent permitted by applicable law, Greek Coin OÜ, its shareholders, directors, employees, agents, attorneys, representatives, suppliers, service providers or officers, will in no event be held liable for any indirect, special, consequential or other incidental damage or liabilities including, arising out of our services, statements, actions, products, or other information or item related to Greek Coin OÜ, except to the extent of a final judicial determination that such damages were a result of the Company’s gross negligence, fraud, willful misconduct or intentional violation of law. Some jurisdictions do not allow the exclusion or limitation of incidental or consequential damages and thus users from such jurisdictions may be excluded from the above limitation.
        """]
          , li[][text """For example, the Company shall not be liable for:
            """
      , ol[class "countable"][li[][text """losses incurred by the User resulting from effectively implemented Transactions;
            """]
          , li[][text """incorrect entering of data by the User into deposit or withdrawal of the Cash Funds or Cryptocurrencies;
            """]
          , li[][text """effects of events beyond the Company’s control, i.e. software errors, interruptions in the Internet access, power cuts, hacking attacks (despite maintaining adequate measures described on the Website), etc.;
            """]
          , li[][text """deletion of data entered by the Users into the Company’s IT system from IT systems beyond the Company’s control.
         """] ] ]
          , li[][text """In the event of a dispute between the User and another User, the User shall indemnify the Company against all claims and claims for damage (actual or lost benefits) of any kind resulting from or in any way related to such disputes.
        """]
          , li[][text """The User undertakes to indemnify the Company from all claims and to repair any damage (including the costs of legal assistance, any fines, fees or penalties imposed by any state authorities) resulting from or related to the User’s violation of these Regulations or infringement of legal provisions or rights of third parties.
        """]
          , li[][text """The liability of the Company towards the User is limited to the value of a given Transaction expressed in a given currency or Cryptocurrency and is limited to the value of funds provided by the User for the execution of a given Transaction.
        """]
          , li[][text """The Company will endeavor to process the requests for a Transaction with bank accounts or credit cards without undue delay, but the Company does not provide any assurances or guarantees regarding the time needed to complete the processing of such Transactions, which is dependent on many factors beyond the Company’s control.
        """]
          , li[][text """The Company shall not be liable for any actions or consequences of force majeure, i.e. for events beyond the Company’s reasonable control which occurred without fault of the Company, including, in particular: embargoes, governmental restrictions, riots, insurrection, wars or other acts of war, acts of terror, social unrest, rebellion, hacking attacks (including DDoS attacks, data theft or destruction), fires, floods, vandalism or sabotage, Pandemics, governmental restrictions or lock-downs.
        """]
          , li[][text """The Company shall exercise the utmost care in order to protect the Website and User’s Personal Data and Funds against undesirable interference by third parties or software malwares. The security measures taken are described in the Privacy Policy, the content of which the User has read and accepts – considering that the security measures taken by the Company are sufficient.
        """]
          , li[][text """You shall indemnify the Company from any action, omission or other direct or indirect act that may lead to your or other user’s damage, loss of property and/or funds and/or personal data, or delay in the execution of orders. The company shall not be held liable for any such act that has not been authorized or was authorized based on tampered facts, forced documents or other incomplete information.

     """] ] ]
    , li[class "countable"][text """Personal Data and Privacy Policy

The principles of personal data processing by the Company and regulations concerning the Privacy Policy and Cookies are contained in the Privacy Policy published on the Website.

    """]
    , li[class "countable"][text """Resolving Disputes

        """
      , ol[class "countable"][li[][text """PLEASE READ THIS SECTION CAREFULLY, AS IT INVOLVES A WAIVER OF CERTAIN RIGHTS TO BRING LEGAL PROCEEDINGS, INCLUDING AS A CLASS ACTION FOR RESIDENTS OF THE U.S.
        """]
          , li[][text """Notification of Dispute. You shall address any of your concerns to the Company prior to resorting to formal proceedings. Before filing a claim, you agree to try to resolve the dispute informally through our contact details.
        """]
          , li[][text """Agreement to Arbitrate. You and Greek Coin OÜ agree to resolve any claims relating to these Terms through final and binding arbitration, except as set forth under Exceptions to Agreement to Arbitrate below. You agree to first give us an opportunity to resolve any claims by contacting us as set forth in paragraph 14.2 above. If we are not able to resolve your claims within 60 days of receiving the notice, you may seek relief through arbitration.
        """]
          , li[][text """Arbitration Procedure. Either you or Greek Coin OÜ may submit a dispute (after having made good faith efforts to resolve such dispute in accordance with paragraphs 14.2 and 14.3 above) for final and binding resolution by arbitration. Judgment on any arbitral award may be given in any court having jurisdiction over the party (or over the assets of the party) against whom such an award is rendered.
        """]
          , li[][text """Notice. To begin an arbitration proceeding, you must send a letter requesting arbitration and describing your claims to our contact e-mail or our physical address.

     """] ] ]
    , li[class "countable"][text """Miscellaneous

        """
      , ol[class "countable"][li[][text """Entire Agreement. These Terms constitute the entire agreement between the parties regarding use of our Services and will supersede all prior written or oral statements or agreements between the parties.
        """]
          , li[][text """Interpretation and Revision. We reserve the right to alter, revise, modify, and/or change these Terms at any time. All changes will take effect immediately upon being published on our websites. It is your responsibility to regularly check relevant pages on our websites/applications to confirm the latest version of these Terms. If you do not agree to any such modifications, your only remedy is to terminate your usage of our Services and cancel your account. You agree that, unless otherwise expressly provided in these Terms, we will not be responsible for any modification or termination of our Services by you or any third party, or suspension or termination of your access to our Services.
        """]
          , li[][text """Force Majeure. We will not be liable for any delay or failure to perform as required by these Terms because of any cause or condition beyond our reasonable control as mentioned above on clause 12.10.
        """]
          , li[][text """Severability. If any portion of these Terms is held invalid or unenforceable, such invalidity or enforceability will not affect the other provisions of these Terms, which will remain in full force and effect, and the invalid or unenforceable portion will be given effect to the greatest extent possible.
        """]
          , li[][text """Third-Party Website Disclaimer. Any links to third-party websites from our Services does not imply endorsement by Greek Coin OÜ of any product, service, information or disclaimer presented therein, nor does we guarantee the accuracy of the information contained on them. If you suffer loss from using such third-party product and service, we will not be liable for such loss. In addition, since the Company has no control over the terms of use or privacy policies of third-party websites, you should read and understand those policies carefully.
        """]
          , li[][text """Contact Information. For more information on Greek Coin OÜ, you may refer to the company and license information found on our website.
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
              h1 [][ span[][ text "Terms of service"]]
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
