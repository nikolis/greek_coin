module Page.Legal.Kyc exposing (..)

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
    { title = "KYX AML"
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
                 span[style "font-size" "3rem", style "font-weight" "bold", style "color""white"][text "KYC/AML/CTF Policy"]
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
                    h3[style "font-weight" "bold"][text "Greek Coin OÜ Privacy Notice"]
                 ]
             ]

          ,  div[class "row"]
             [
                 div[class "col"]
                 [

   ol[class " countable "][li[][text """INTRODUCTION
GREEK COIN OÜ P.L.C (the “Company”), is a company incorporated under the Estonian Commercial Code, with registration number 14787392 and authorized by the Estonian Financial Supervisory Authority to operate as a Private Limited Company which offers Financial Services, and that includes: a) Providing a virtual currency wallet service (Activity License FRK001080) and b) Providing services of exchanging a virtual currency against a fiat currency (Activity license FVR001195).

    """]
    , li[class "countable"][text """LEGAL FRAMEWORK
        """
      , ol[class "countable"][li[][text """The Company understands that as a Virtual Currency (VC) service provider, is treated equally to a financial Institution, which is operating under the following legal basis:
            """
      , ol[class "countable"][li[][text """Estonian Law Money Laundering and Terrorist Financing Prevention Act issued by Riigikogu (the unicameral parliament of Estonia) which entered into force on the 10th of March 2020 (hereinafter ‘The Act’), with their office, Management and AML officer situating in Estonia, namely, Harju Μaakond, Tallinn, Kesklinna linaosa, Roseni tn 13,  """] ] ]
    , li[class "countable"][text """
            """]
          , li[][text """Personal Data Protection Act issued by Riigikogu which entered into force in 15th of January 2019.
            """]
          , li[][text """Identity Documents Act which entered into force by Riigikogu in the 1st of January 2000 and as amended until the 15th of September 2013.
            """]
          , li[][text """Directive (EU) 2015/849 of the European Parliament and of the Council of 20 May 2015 on the prevention of the use of the financial system for the purposes of money laundering or terrorist financing, amending Regulation (EU) No 648/2012 of the European Parliament and of the Council, and repealing Directive 2005/60/EC of the European Parliament and of the Council and Commission Directive 2006/70/EC.
            """]
          , li[][text """Directive 2014/65/EU of the European Parliament and of the Council of 15 May 2014 on markets in financial instruments (MiFID II) and amending Directive 2002/92/EC and Directive 2011/61/EU Text with EEA relevance.
            """]
          , li[][text """Regulation (EU) 2016/679 of the European Parliament and of the Council of 27 April 2016 on the protection of natural persons with regard to the processing of personal data and on the free movement of such data, and repealing Directive 95/46/EC (General Data Protection Regulation).
        """
      , ol[class "countable"][li[][text """The Company recognizes that a strong AML & CTF manual is essential for the apt operation of the Company and its protection from being used to launder money or to finance terrorism. Thus, the Company has adopted a series of principles and procedures against money laundering and terrorism financing based on specific risk profile of its activities, and geographic location.
         """] ] ]
          , li[][text """This is a short version of the company’s AML/CFT and Risk Assessment manual explaining the procedures and the bases on which personal information are collected and used.

     """] ] ]
    , li[class "countable"][text """COLLECTION OF INFORMATION
        """
      , ol[class "countable"][li[][text """The Company needs to comply with global regulatory standards including Anti-Money Laundering (AML), Counter Terrorist Financing (CTF) and Know-Your-Customer (KYC) requirements. These regulatory standards require formal identification and thus we collect such a wide range of information to fulfil the binding legal provisions regarding the obligation to identify the client, to monitor the transactions, combat and assess the risks of fraud, money laundering and financing of terrorism.
        """]
          , li[][text """Therefore, it is crucial for our clients to provide the data requested during the registration and verification procedure. The obligation for such an identification and verification does not allow the Company to proceed with the establishment of a business relationship if the data proves to be false, or if you object to its processing. In order to verify the accuracy of the data provided by you and to assess the risk of fraud, we also monitor your transaction history by analyzing the course, volume, currency and type of transactions.
        """]
          , li[][text """The Company has either a regulatory obligation to collect those types of data or the legitimate interest of having them in order to provide the Services or a contractual agreement between you and the company.
        """]
          , li[][text """The Company processes the required personal data based on your consent and any further information you provide to us without the need to do so, the Company deems that you provide such data voluntarily, but will be deleted if deemed not useful for the operation of the company’s business.
        """]
          , li[][text """The Company keeps all the information strictly confidential and uses it only for the purposes of compliance with the Law and the execution of internal and communication procedures. For any other use, the Client is informed prior to the retrieval of any information. Find more in the Privacy Policy of the Website.
        """]
          , li[][text """As part of the compliance to the relevant Act and Regulations, the Client may be asked to provide us with the following personal data:
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
          , li[][text """information concerning the identity document (passport or identity card)
            """]
          , li[][text """photo
            """]
          , li[][text """bank account number
            """]
          , li[][text """Personal (national) Identification Number
            """]
          , li[][text """e-mail address
            """]
          , li[][text """Bitcoin Address or other cryptocurrencies addresses
            """]
          , li[][text """Further data necessary for the identification of the new Client or the identification of the source of wealth, for verification and AML compliance purposes.
            """]
          , li[][text """other data such as –  request URL, domain name, device ID, browser type, browser language, number of clicks, amount of time spent on individual pages, date and time stamp of using the Website, type and version of the operating system, screen resolution, data collected in the server logs, and other similar information to develop statistical data for the optimization of services rendered, including displaying content that complies with your preferences.


      """] ] ]  ] ]
    , li[class "countable"][text """DEFINITIONS
The following definitions of this Policy derive from and must be read according to the definitions of the Estonian Law (Money Laundering and Terrorist Financing Prevention Act issued by Riigikogu (the unicameral parliament of Estonia) which entered into force on the 10th of March 2020) (hereinafter ‘The Act’), with their office, Management and AML officer situating in Estonia, namely, Harju Μmaakond, Tallinn, Kesklinna linaosa, Roseni tn 13, """]
    , li[class "countable"][text """Any word or phrase not defined in this section shall be interpreted according to the Definitions of the Estonian Law and according to that meaning and reading. Where the Definitions refer to an Act or Regulation, they refer to the relevant Act of the Estonian Law.
        """
      , ol[class "countable"][li[][text """‘Beneficial owner’
(1) For the purposes of this Act, ‘beneficial owner’ means a natural person who, taking advantage of their influence, makes a transaction, act, action, operation or step or otherwise exercises control over a transaction, act, action, operation or step or over another person and in whose interests or favour or on whose account a transaction or act, action, operation or step is made.
(2) In the case of companies, a beneficial owner is the natural person who ultimately owns or controls a legal person through direct or indirect ownership of a sufficient percentage of the shares or voting rights or ownership interest in that person, including through bearer shareholdings, or through control via other means.
(3) Direct ownership is a manner of exercising control whereby a natural person holds a shareholding of 25 per cent plus one share or an ownership interest of more than 25 per cent in a company. Indirect ownership is a manner of exercising control whereby a company which is under the control of a natural person holds or multiple companies which are under the control of the same natural person hold a shareholding of 25 per cent plus one share or an ownership interest of more than 25 per cent in a company.
(4) Where, after all possible means of identification have been exhausted, the person specified in subsection 2 of this section cannot be identified and there is no doubt that such person exists or where there are doubts as to whether the identified person is a beneficial owner, the natural person who holds the position of a senior managing official is deemed as a beneficial owner.
(5) The obliged entity registers and keeps records of all actions taken in order to identify the beneficial owner under subsections 2 and 4 of this section.
(6) In the case of a trust, civil law partnership, community or legal arrangement, the beneficial owner is the natural person who ultimately controls the association via direct or indirect ownership or otherwise and is such associations’:
        a. settlor or person who has handed over property to the asset pool;
        b. trustee or manager or possessor of the property;
        c. person ensuring and controlling the preservation of property, where such person has been appointed, or the beneficiary, or where the beneficiary or beneficiaries have yet to be determined, the class of persons in whose main interest such association is set up or operates.
(7) In the case of a person or an association of persons not specified in subsections 2 and 6 of this section, a member or members of the management board may be designated as a beneficial owner.
(8) ‘Control via other means’ means the exercising of dominant influence in accordance with the criteria set out in subsection 1 of § 27 of the Accounting Act.
(9) This section does not apply to a company listed on a regulated market that is subject to disclosure requirements consistent with European Union law or subject to equivalent international standards which ensure adequate transparency of ownership information.
        4.1 ‘Business relationship’ means a relationship that is established upon conclusion of a long-term contract by an obliged entity in economic or professional activities for the purpose of provision of a service or sale of goods or distribution thereof in another manner or that is not based on a long-term contract, but whereby a certain duration could be reasonably expected at the time of establishment of the contact and during which the obliged entity repeatedly makes separate transactions in the course of economic or professional activities while providing a service or professional service, performing professional acts or offering goods.
        4.2 ‘Customer or Client’ means a person who has a business relationship with the Company.
        4.3 ‘Criminal activity’ means any kind of criminal involvement in the commission of the following crimes:
            4.3.1 terrorist offences, offences related to a terrorist group and offences related to terrorist activities as set out in Titles II and III of Directive (EU) 2017/541;
            4.3.2 any of the offences referred in Article 3(1)(a) of the 1988 United Nations Convention against Illicit Traffic in Narcotic Drugs and Psychotropic Substances;
            4.3.3 the activities of criminal organizations as defined in Article 1 of Council Framework Decision 2008/841/JHA;
            4.3.4 fraud affecting the Union's financial interests, where it is at least serious, as defined in Article 1(1) and Article 2(1) of DIRECTIVE (EU) 2017/1371 on the fight against fraud to the Union's financial interests by means of criminal law;
            4.3.5 corruption (“the abuse of power for private gain. Corruption takes many forms, such as bribery, trading in influence, abuse of functions, but can also hide behind nepotism, conflicts of interest, or revolving doors between the public and the private sectors.”);
            4.3.6 all offences, including tax crimes relating to direct taxes and indirect taxes and as defined in the national law of the EU Member States, which are punishable by deprivation of liberty or a detention order for a maximum of more than one year or, as regards EU Member States that have a minimum threshold for offences in their legal system, all offences punishable by deprivation of liberty or a detention order for a minimum of more than six months.
        4.4 ‘Custodian wallet provider’ means an entity that provides services to safeguard private cryptographic keys on behalf of its customers, to hold, store and transfer virtual currencies.
        4.5 ‘High-risk Third Country’ means a country specified in a delegated act adopted on the basis of Article 9(2) of Directive (EU) 2015/849 of the European Parliament and of the Council on the prevention of the use of the financial system for the purposes of money laundering or terrorist financing, amending Regulation (EU) No 648/2012 of the European Parliament and of the Council, and repealing Directive 2005/60/EC of the European Parliament and of the Council and Commission Directive 2006/70/EC (OJ L 141/73, 05.06.2015, pp 73–117).
        4.6 ‘Joint Guidelines’ means the guidelines on the risk factors issued by the European Securities and Markets Authority, the European Insurance and Occupational Pensions Authority and the European Banking Authority under Articles 17 and 18(4) of Directive (EU) 2015/849 on simplified and enhanced customer due diligence and the factors credit and financial institutions should consider when assessing the money laundering and terrorist financing risk associated with individual business relationships and occasional transactions, as amended.
        4.7 ‘Politically exposed person’ means a natural person who is or who has been entrusted with prominent public functions and includes the following: (a) heads of State, heads of government, ministers and deputy or assistant ministers; (b) members of parliament or of similar legislative bodies; (c) members of the governing bodies of political parties; (d) members of supreme courts, of constitutional courts or of other high-level judicial bodies, the decisions of which are not subject to further appeal, except in exceptional circumstances; (e) members of courts of auditors or of the boards of central banks; (f) ambassadors, chargés d'affaires and high-ranking officers in the armed forces; (g) members of the administrative, management or supervisory bodies of State-owned enterprises; (h) directors, deputy directors and members of the board or equivalent function of an international organization. No public function referred to in points (a) to (h) shall be understood as covering middle-ranking or more junior officials.
        4.8 ‘Persons known to be close associates’ means: (a) natural persons who are known to have joint beneficial ownership of legal entities or legal arrangements, or any other close business relations, with a politically exposed person; (b) natural persons who have sole beneficial ownership of a legal entity or legal arrangement which is known to have been set up for the de facto benefit of a politically exposed person.
        4.9 ‘Senior management of obliged entity’ means an officer or employee with sufficient knowledge of the institution's money laundering and terrorist financing risk exposure and sufficient seniority to take decisions affecting its risk exposure, and need not, in all cases, be a member of the management of the Company.
        4.10 ‘Virtual currencies’ means a value represented in the digital form, which is digitally transferable, preservable or tradable and which natural persons or legal persons accept as a payment instrument, but that is not the legal tender of any country or funds for the purposes of Article 4(25) of Directive (EU) 2015/2366 of the European Parliament and of the Council on payment services in the internal market, amending Directives 2002/65/EC, 2009/110/EC and 2013/36/EU and Regulation (EU) No 1093/2010, and repealing Directive 2007/64/EC (OJ L Money Laundering and Terrorist Financing Prevention Act Page 3 / 39 337, 23.12.2015, pp. 35–127) or a payment transaction for the purposes of points (k) and (l) of Article 3 of the same Directive.
        4.11 ‘Property’ means any object as well as the right of ownership of such object or a document certifying the rights related to the object, including an electronic document, and the benefit received from such object;
        4.12 ‘Sanctions Law’ means the Implementation of the provisions of the United Nations Security Council Resolutions or Decisions (Sanctions) and the European Union Council Decisions and Regulations (Restrictive Measures) Law 58(I) of 2016.
        4.13 ‘Virtual Currency Service’ means a virtual currency wallet service’ and a virtual currency exchange service’.
        4.14 ‘Virtual Currency Wallet Service’ means a service in the framework of which keys are generated for customers or customers’ encrypted keys are kept, which can be used for the purpose of keeping, storing and transferring virtual currencies.
        4.15 ‘Virtual Currency Exchange Service’ means a service through which a person exchanges a virtual currency against a fiat currency or a fiat currency against a virtual currency or a virtual currency against another virtual currency.

    5 ‘CLIENT RISK CATEGORIZATION
        5.1 The Company will use these Data to better know the Client and better comply with the relevant regulations that require monitoring of Clients’ trading activity. The ultimate scope is to protect the Financial Market and the European Interests from Money Laundering and Terrorism Financing.
        5.2 There are some factors that categorize the client’s risk to low, medium or high risk. That leads to lower or higher scrutiny procedure accordingly, called due diligence.
        5.3 The Company takes into consideration the following factors for clients’ risk categorization:
            5.3.1 Clients’ background - this includes the profession of the client, his/her knowledge and experience with the financial instruments and/or type of investment services, academic or other qualifications, etc.;
            5.3.2 Type and nature of client’s business – brief description of the client’s work experience and area of expertise;
            5.3.3 Country of origin - this parameter will allow the Company to identify whether the client is located in a third country, or sanctioned country, which may be considered suspicious for money laundering. In such cases the Company will ask for additional information regarding the client to ensure that such possibility is eliminated;
            5.3.4 The services and financial instruments applied for and the anticipated level and nature of business transactions – this information is collected in order to ensure that they correspond to the client’s profile;
            5.3.5 Expected source and origin of funds - this is considered an important parameter as it allows the Company to ascertain whether any of the funds of the client are the result of money laundering or criminal activities.
        5.4 The following is a non-exhaustive list of factors and types of evidence of potentially lower risk referred to in Article 16 of the (EU) 2015/849 Directive:
            5.4.1 Customer risk factors:
    a. public companies listed on a stock exchange and subject to disclosure requirements (either by stock exchange rules or through law or enforceable means), which impose requirements to ensure adequate transparency of beneficial ownership;
    b. public administrations or enterprises;
    c. customers that are resident in geographical areas of lower risk as set out in point (5.4.3).
            5.4.2 Product, service, transaction or delivery channel risk factors:
    a. life insurance policies for which the premium is low;
    b. insurance policies for pension schemes if there is no early surrender option and the policy cannot be used as collateral;
    c. a pension, superannuation or similar scheme that provides retirement benefits to employees, where contributions are made by way of deduction from wages, and the scheme rules do not permit the assignment of a member's interest under the scheme;
    d. financial products or services that provide appropriately defined and limited services to certain types of customers, so as to increase access for financial inclusion purposes;
    e. products where the risks of money laundering and terrorist financing are managed by other factors such as purse limits or transparency of ownership (e.g. certain types of electronic money).
            5.4.3 Geographical risk factors — registration, establishment, and residence in:
    a. another EU Member State;
    b. third countries having effective AML/CFT systems;
    c. third countries identified by credible sources as having a low level of corruption or other criminal activity;
    d. third countries which, on the basis of credible sources such as mutual evaluations, detailed assessment reports or published follow-up reports, have requirements to combat money laundering and terrorist financing consistent with the revised FATF Recommendations and effectively implement those requirements.

        5.5 The following is a non-exhaustive list of factors and types of evidence of potentially higher risk referred to in Article 18(3) of the (EU) 2015/849 Directive:

            5.5.1 Customer risk factors:
    a. the business relationship is conducted in unusual circumstances;
    b. customers that are resident in geographical areas of higher risk as set out in point (5.5.3);
    c. legal persons or arrangements that are personal asset-holding vehicles;
    d. companies that have nominee shareholders or shares in bearer form;
    e. businesses that are cash-intensive;
    f. the ownership structure of the company appears unusual or excessively complex given the nature of the company's business;
    g. customer is a third country national who applies for residence rights or citizenship in an EU Member State in exchange of capital transfers, purchase of property or government bonds, or investment in corporate entities in that Member State.
            5.5.2 Product, service, transaction or delivery channel risk factors:
    a. private banking;
    b. products or transactions that might favor anonymity;
    c. non-face-to-face business relationships or transactions, without certain safeguards, such as electronic signatures identification means, relevant trust services as defined in Regulation (EU) No 910/2014 or any other secure, remote or electronic, identification process regulated, recognized, approved or accepted by the relevant national authorities;
    d. payment received from unknown or unassociated third parties;
    e. new products and new business practices, including new delivery mechanism, and the use of new or developing technologies for both new and pre-existing products;
    f. transactions related to oil, arms, precious metals, tobacco products, cultural artefacts and other items of archaeological, historical, cultural and religious importance, or of rare scientific value, as well as ivory and protected species.
            5.5.3 Geographical risk factors:
    a. countries identified by credible sources, such as mutual evaluations, detailed assessment reports or published follow-up reports, as not having effective AML/CFT systems;
    b. countries identified by credible sources as having significant levels of corruption or other criminal activity;
    c. countries subject to sanctions, embargos or similar measures issued by, for example, the Union or the United Nations;
    d. countries providing funding or support for terrorist activities, or that have designated terrorist organizations operating within their country.

    6 CLIENTS ACCEPTANCE POLICY

        6.1 The Client’s acceptance process is the following:
            6.1.1 Any new client has to submit certified copies of the documents required according to KYC;
            6.1.2 The Compliance department collects the necessary documents and makes a preliminary examination of the documents submitted, verifies that the information provided is comprehensive, complete and valid, and does not contradict with any other information known to the Company from other sources;
            6.1.3 A potential client may be asked to fill in a questionnaire that incorporates further information, for the Company to make a decision regarding client’s knowledge and experience, his attitude to risk and financial position, so as to perform suitability test, assign an appropriate categorization (protection) and investment strategy. This information will also be used following the establishment of a relationship with the clients for the performance of the appropriateness test;
            6.1.4 After all necessary information is collected and analyzed, and provided that no reasons were identified to decline a client, the necessary documents are sent to the Compliance/Anti-Money Laundering Officer for approval;
            6.1.5 After the final approval by the Compliance/AML Officer, the new client is provided with the necessary MiFID information as well as the agreement to be accepted;
            6.1.6 When the client accepts the agreement, a new client account is opened in the Company’s system and the list of clients is updated so as to include the relevant information regarding the new client;
            6.1.7 In the case of client’s transactions via the internet or phone where the client is not present so as to verify the authenticity of his signature or that he is the real owner of the account or that he has been properly authorized to operate the account, the Company applies reliable methods, procedures and control mechanisms over the access to the electronic means so as to ensure that it deals with the true owner or the authorized signatory to the account.

        6.2 Clients will not be accepted for opening an account with the Company if:
            6.2.1 they refuse to provide the information required according to the Company’s KYC procedures;
            6.2.2 they refuse to submit enough information for the performance of the suitability and appropriateness test;
            6.2.3 the documents submitted appear to be faulty at the examination stage;
            6.2.4 there is a reason to doubt the authenticity of the documents submitted;
            6.2.5 the client, in case of a corporate entity, was refused the granting of a license or had his license suspended or withdrawn;
            6.2.6 the origin of wealth and/or source of funds cannot be easily verified;
            6.2.7 the beneficial owners or any of the directors of a client are on the list of people involved in terrorist financing or known to be involved in activity connected to money-laundering;
            6.2.8 the Company or any of the related companies had business relationship with the client in the past and they were terminated due to the client not meeting its obligations;
            6.2.9 the client is in under investigation by supervisory authorities;
            6.2.10 the client is under the age of 18 years old.

    7 DUE DILIGENCE MEASURES
Customer due diligence (CDD) involves identifying and getting to know all natural or legal persons intending to establish business relationships or conducting any transactions with the company. It is not possible to maintain business relationships or carry out transactions with natural or legal persons that have not been properly identified. The Company must apply CDD measures before entering into a business relationship or carrying out an occasional transaction.
        7.1 The CDD measures to be implemented are the following:
            7.1.1 identification of a customer or a person participating in an occasional transaction and verification of the submitted information based on information obtained from a reliable and independent source, including using means of electronic identification and of trust services for electronic transactions;
            7.1.2 identification and verification of a customer or a person participating in an occasional transaction and their right of representation;
            7.1.3 identification of the beneficial owner and, for the purpose of verifying their identity, taking measures to the extent that allows the obliged entity to make certain that it knows who the beneficial owner is, and understands the ownership and control structure of the customer or of the person participating in an occasional transaction;
            7.1.4 understanding of business relationships, an occasional transaction or act and, where relevant, gathering information thereon.
            7.1.5 gathering information on whether a person is a politically exposed person, their family member or a person known to be close associate;
            7.1.6 Conducting ongoing due diligence on the business relationship and scrutiny of transactions undertaken throughout the course of that relationship to ensure that the transactions being conducted are consistent with the Company's knowledge of the customer, the duration of the business relationship, the volume of the property deposited by the customer or the proprietary volume of the transaction or of transactions made in course of a professional act, their business and risk profile, including, where necessary, the source of funds.
        7.2 The Company as obliged entity applies due diligence measures:
            7.2.1 upon establishment of a business relationship;
            7.2.2 upon making or mediating occasional transactions outside a business relationship where a cash payment of over 15,000 euros or an equal amount in another currency is made, regardless of whether the financial obligation is performed in the transaction in a lump sum or in several related payments over a period of up to one year, unless otherwise provided by law;
            7.2.3 upon verification of information gathered while applying due diligence measures or in the case of doubts as to the sufficiency or truthfulness of the documents or data gathered earlier while updating the relevant data;
            7.2.4 upon suspicion of money laundering or terrorist financing, regardless of any derogations, exceptions or limits provided for in the Act.
        7.3 The Company applies due diligence measures at least every time a payment of over 10,000 euros or an equal sum in another currency is made to or by the trader in cash, regardless of whether the pecuniary obligation is performed in a lump sum or by way of several linked payments over a period of up to one year.
        7.4 The Company applies the due diligence measures provided in clauses 1–5 of subsection 1 of § 20 of the Act before each establishment of a business relationship or the making of each transaction outside a business relationship, unless otherwise provided for in the Act.
        7.5 If the Company finds out, at any stage of the business relationship with an existing client, that valid or sufficient documentation or information is not available regarding his identity and economic profile, the Company applies all necessary procedures and carry out due diligence measures in order to collect the missing documentation and information as quickly as possible, in order to form the complete economic profile of the client.
        7.6 Further enquiries may be appropriate in cases where after the application of CDD procedures, the information and documentation obtained is not of sufficient quality to satisfy the Company that:
a) the identity of the prospective client and corresponding UBO has been adequately verified; or
b) there is a thorough understanding of the ownership and control structure; or
c) there is enough information to assess the purpose and intended nature of business relationship. If the Company, following further enquiries still has doubts or the client did not provide the information requested within a reasonable time, the business relationship may be declined or terminated.
        7.7 The Company is required to conduct background screening and perform background checks against sanctions lists and PEPs lists and in order to determine whether any negative information exists regarding the potential client that might affect the risk emanating from the client. Background screening should form part of the initial CDD process and during any change-driven updates of the CDD or during scheduled/ routine CDD updates. The results of the background screening should be appropriately documented and incorporated in the risk-based process of the firm, e.g., high risk clients. Partial matches as well as false positives should be maintained with an explanation on why they do not pose a concern or why they have been disregarded as a match for further examination.
        7.8 The Company must terminate or refuse to enter into a business relationship – depending on the case – if it cannot comply with the identification, verification and evaluation of the nature of the business relationship requirements. Moreover, nothing must be communicated to the client (or to any other person) which might prejudice an investigation or proposed investigation by the law enforcement agencies, as this will be considered as “tipping off”.
        7.9 By way of derogation from the contents of the current section, the Company may allow the verification of the identity of the client and the beneficial owner to be completed during the establishment of a business relationship, if this is necessary for not interrupting the normal conduct of business and where the risk of money laundering or terrorist financing occurring is low.
    8 KNOW YOUR CLIENT PROCEDURES FOR NATURAL AND LEGAL PERSONS
        8.1 Identification and Verification of Natural Persons
            8.1.1 The Company may identify the Client at first through an official travel document (identity card or passport) and if this is not possible the Company may use other means of identification as described in article 2 section 2 of the Identity Documents Act of the Estonian Law.
            8.1.2 According to the Identity Documents Act, via
                8.1.2.1 an identity card;
                8.1.2.2 a digital identity card;
[RT I 2009, 27, 166 - entry into force 30.07.2009]
                8.1.2.3  a residence permit card;
[RT I, 09.12.2010, 1 - entry into force 01.01.2011]
                8.1.2.4  an Estonian citizen’s passport;
                8.1.2.5  a diplomatic passport;
                8.1.2.6  a seafarer’s discharge book;
                8.1.2.7  an alien’s passport;
                8.1.2.8  a temporary travel document;
                8.1.2.9  a travel document for a refugee;
                8.1.2.10 a certificate of record of service on ships;
                8.1.2.11 a certificate of return;
                8.1.2.12 a permit of return.
            8.1.3 Where the original document is not available, the identity can be verified on the basis of a document, which has been authenticated by a notary or certified by a notary or official, or on the basis of other information originating from a credible and independent source, including means of electronic identification and trust services for electronic transactions, thereby using at least two different sources for verification of data in such an event.

        8.2 Additional information:
            8.2.1 the source and size of wealth,
            8.2.2 the signature,
            8.2.3 the profession or occupation and any other relevant information should also be obtained if judged necessary to perform all obligations under the Law.

        8.3 Identification and verification of legal entities
The Company identifies a legal person registered in Estonia, the branch of a foreign company registered in Estonia and a foreign legal person and retains the following details on the legal person:
            8.3.1 the name or business name of the legal person;
            8.3.2 the registry code or registration number and the date of registration;
            8.3.3 the names of the director, members of the management board or other body replacing the management board, and their authorisation in representing the legal person;
            8.3.4 the details of the telecommunications of the legal person.
        8.4 The Company verifies the correctness of the data using information originating from a credible and independent source for that purpose. Where the obliged entity has access to the commercial register, register of non-profit associations and foundations or the data of the relevant registers of a foreign country, the submission of the documents does not need to be demanded from the customer.
        8.5 A representative of a legal person of a foreign country must, at the request of the Company, submit a document certifying his or her powers, which has been authenticated by a notary or in accordance with an equal procedure and legalized or certified by a certificate replacing legalisation (apostille), unless otherwise provided for in an international agreement.
        8.6 Prospective clients which are legal entities, depending on the complexity of their organizations and structures, may pose significant difficulties in identifying and verifying their legal existence. Hence, firms should treat with care such prospective clients and ensure that any person purporting to act on such clients’ behalf is duly authorized and has the mandate to do so and identify and verify that person.
        8.7 The Company is required to identify and take reasonable measures to understand the ownership and control structure, duly identifying the beneficial owners of the client and documenting their findings in a diligent manner. Enquiries should also be made to confirm that the entity exists for a legitimate trading or economic purpose and that the controlling persons can be identified.
        8.8 Certified true copies of the original documentation verifying the information gathered regarding clients which are legal entities, should be obtained in accordance with the provisions (EU) 2015/849 Directive. The certification of the documentation should indicate that the document is a “Certified true copy of the original”, stating the certifier’s name, capacity and the date of certification.
        8.9 Moreover, the company should identify the principal directors/partners, persons with significant control and beneficial shareholders of each client legal entity, in line with the requirements for natural persons.
        8.10 Know Your Client (KYC) is an on-going process. If the Company becomes aware of changes to the client’s structure or ownership, or if suspicions arise by a change in the nature of the business transacted, further checks should be made to ascertain the reason for the changes.
    9 ON-GOING MONITORING OF TRANSACTIONS AND ACCOUNTS

        9.1 The procedures and intensity of monitoring accounts and examining transactions will be based on the level of risk and, as a minimum, achieve the following:
            9.1.1 identifying all high-risk customers. Therefore, the systems or the measures and procedures of the Company will be able to produce detailed lists of high-risk customers so as to facilitate enhanced monitoring of accounts and transactions;
            9.1.2 detecting of unusual or suspicious transactions that are inconsistent with the economic profile of the customer for the purposes of further investigation;
            9.1.3 the investigation of unusual or suspicious transactions from the employees who have been appointed for that purpose; the results of the investigations are recorded in a separate memo and kept in the file of the customer concerned;
            9.1.4 ascertaining the source and origin of the funds credited to accounts.
        9.2 Ongoing monitoring is a vital part of effective Anti-money laundering and counter terrorist financing compliance systems. Ongoing monitoring procedures assist the Company as obliged entity to update existing knowledge on its clients and detect any unusual or suspicious activities. Ongoing monitoring procedures should be customized depending on the type of services offered to the client. An audit client’s ongoing monitoring procedures should differ from the monitoring procedures adopted for a client that obtains directorship or bank management services.
        9.3 In cases where the substance of a business relationship changes significantly, the Company performs additional CDD procedures to identify and subsequently mitigate the money laundering and terrorist financing risks involved. If the revised risk is not in line with the Client Acceptance Policy of the Company, then consideration should be made to terminate the business relationship.
        9.4 Changes in the terms of a business relationship with clients may include amongst others, the following:
            9.4.1 Changes in the shareholding structure;
            9.4.2 Changes in the activities or turnover of a client that do not have commercial rationale;
            9.4.3 Enquiries and provision of new higher risk services;
            9.4.4 Changes in the nature of transactions of a client that cannot be explained;
            9.4.5 Set up of new corporate structures.
        9.5 Depending on the findings of ongoing monitoring procedures, the Company should consider the reclassification of a client risk profile and subsequently the application of risk appropriate due diligence measures. Sufficient guidance must be given to staff members to enable them to perform effective monitoring.
        9.6 Despite the proportionality principle mentioned above, it must be noted that ongoing monitoring should take place for all client relationships including low risk clients and clients for which Simplified Due Diligence measures were adopted. What can be altered accordingly is the frequency and extent of the ongoing monitoring.
    10 RECORD KEEPING
        10.1 The Compliance Department of the Company maintains records of:
    • Client identification documents obtained (e.g. copies of records of official identification documents like passports, identity cards, driving licenses or similar documents), including the results of any preliminary analyses undertaken (e.g. Inquiries to establish the background and purpose of complex, unusually large transactions) after the date of the transaction; and
    • Details of all relevant business transactions carried out, both locally and internationally, for clients for at least five years (in accordance with article 47(1) of the Act).
        10.2 This information may be used as evidence in any subsequent investigation by the authorities. The records kept by the Compliance department provide audit trail evidence during any subsequent investigation. In practice, the business units of the Company will be routinely making records of work carried out for clients in the course of normal business and these records should be archived.
        10.3 The retention of the documents/data, other than the original documents or their certified true copies that are kept in a hard copy form, may be in other forms, such as electronic form, provided that the Company is able to retrieve the relevant documents/data without undue delay and present them at any time, to the relevant Competent Authority, after a request.
        10.4 The documents obtained, in order to be in compliance with the AML Directive, must be in their original form or in a certified true copy form.
        10.5 In the case that the documents are certified as true copies by a different person than the Company itself or by the third person that the Company relies for the KYC procedures of its client, the documents must be verified for their validity by the relevant public authority.
        10.6 A true translation shall be attached in the case that the above-mentioned documents are in a language other than English.
        10.7 The responsibility for the validity of any unduly certified copies submitted to the Company lies with the Compliance/Anti-Money Laundering Officer. However, the Company shall not be liable for any forged documents, except where it was aware or should have been aware of the forgery.
        10.8 The Company and the approved persons shall be entitled to rely on the truth of duly certified documents submitted by the client in original form or in duly certified copies, except where the Company and the approved persons are in any way aware or should have been aware that the documents submitted by the client are not accurate or provide misleading information.

    11 DATA PROTECTION

        """]
          , li[][text """The Company shall always act in accordance with the provisions of the applicable data protection legal and regulatory framework, including Regulation (EU) 2016/679 (General Protection Regulation) (“the GDPR”).
        """]
          , li[][text """The collection and further processing of personal data, to fulfill the AML and Compliance obligations emanating from the (EU) 2015/849 Directive is considered a matter of public interest. The Company should ensure however, that the collected personal data is not used in any other way nor subjected to any commercial or other incompatible processing. Any sort of incompatible processing may be considered a violation.
        """]
          , li[][text """The Company should inform its potential clients prior to initiating a new client relationship or the execution of an occasional transaction, of the type of data required to fulfill their AML and Compliance obligations (e.g. Name of client, Residential address of client etc.). In addition, the Company must communicate to the clients with clarity the legal basis (or bases) of processing as well as the type of processing the company will perform with the collected information, in accordance with the GDPR.
        """]
          , li[][text """The Company also informs its potential and existing clients of the rights conferred to them via Articles 15, 16, 17, 18 and 20 of the GDPR, and provide them with specific steps and contact details (such as the Firm’s Data Protection Officer) so that such potential and existing clients can exercise those rights.
        """]
          , li[][text """The Company shall clearly explain that the rights referred to the clause above are not absolute, especially in relation to the need to avoid jeopardizing money laundering and/or terrorist financing inquiries, analyses or investigations.

        """]
          , li[][text """The Company registers:
            """
      , ol[class "countable"][li[][text """the transaction date or period and a description of the substance of the transaction.
            """]
          , li[][text """information on the circumstance of the Company’s refusal to establish a business relationship or make an occasional transaction;
            """]
          , li[][text """the circumstances of a waiver to establish a business relationship or make a transaction, including an occasional transaction, on the initiative of a person participating in the transaction or professional act, a person using the official service or a customer where the waiver is related to the application of due diligence measures by the Company;
            """]
          , li[][text """information according to which it is not possible to take the due diligence measures provided for in subsection 1 of § 20 of the Act using information technology means;
            """]
          , li[][text """information on the circumstances of termination of a business relationship in connection with the impossibility of application of the due diligence measures;
            """]
          , li[][text """information serving as the basis for the duty to report under § 49 of the Act;
            """]
          , li[][text """upon making transactions with a civil law partnership, community or another legal arrangement, trust fund or trustee, the fact that the person has such status, an extract of the registry card or a certificate of the registrar of the register where the legal arrangement has been registered.

        11.7 The Company retains the originals or copies of the documents specified in §§ 21, 22 and 46 of the Act, which serve as the basis for identification and verification of persons, and the documents serving as the basis for the establishment of a business relationship no less than five years after termination of the business relationship.
        11.8 The Company also retains the entire correspondence relating to the performance of the duties and obligations arising from the Act and all the data and documents gathered in the course of monitoring the business relationship as well as data on suspicious or unusual transactions or circumstances which the Financial Intelligence Unit was not notified of.
        11.9 The Company retains the documents prepared with regard to a transaction on any data medium and the documents and data serving as the basis for the notification obligations specified in § 49 of the Act for no less than five years after making the transaction or performing the duty to report.
        11.10 The Company retains the documents and data in a manner that allows for exhaustively and immediately replying to the enquiries of the Financial Intelligence Unit or, in accordance with legislation, those of other supervisory authorities, investigative bodies or courts, inter alia, regarding whether the Company has or has had in the preceding five years a business relationship with the given person and what is or was the nature of the relationship.
        11.11 Where the Company makes, for the purpose of identifying a person, an enquiry with a database that is part of the state information system, the duties provided for in this subsection will be deemed performed where information on the making of an electronic enquiry to the register is reproducible over a period of five years after termination of the business relationship or making of the transaction.
        11.12 Upon implementation of § 31 of the Act, the Company retains the data of the document prescribed for the digital identification of a person, information on making an electronic enquiry to the identity documents database, and the audio and video recording of the procedure of identifying the person and verifying the person’s identity for at least five years after termination of the business relationship.
        11.13 The Company deletes the data retained on the basis of this section after the expiry of the time limits. On the basis of a precept of the competent supervisory authority, data of importance for prevention, detection or investigation of money laundering or terrorist financing may be retained for a longer period, but not for more than five years after the expiry of the first-time limit.

Protection of Personal Data
        11.14 The Company implements all rules of protection of personal data upon application of the requirements arising from the Act, unless otherwise provided by the Act.
        11.15 The Company is allowed to process personal data gathered upon implementation of the Act only for the purpose of preventing money laundering and terrorist financing and the data must not be additionally processed in a manner that does not meet the purpose, for instance, for marketing purposes.
        11.16 The Company submits information concerning the processing of personal data before establishing a business relationship or making an occasional transaction with any client.

    12 REPORTING
        12.1 The Company has made the necessary arrangements in order to introduce measures designed to assist the functions of the Compliance Officer and the reporting of suspicious transactions by employees and clients. Namely, it has the obligation to ensure that:
            12.1.1 All its employees know to whom they should report a money laundering and/or terrorist financing knowledge or suspicion; and
            12.1.2 There is a clear reporting chain under which money laundering and/or terrorist financing knowledge or suspicion is passed without delay to the Compliance Officer.
  """] ] ]  ] ] ]


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
              h1 [][ span[][ text "KYC AML"]]
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
