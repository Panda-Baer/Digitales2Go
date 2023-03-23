import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/widgets/uploadDTO/uploadFormLayout.dart';
import 'package:textfield_tags/textfield_tags.dart';

import '../../../core/atomic_objects/contact.dart';
import '../../../core/atomic_objects/externalItems.dart';
import '../../../core/enums/enum_util.dart';
import '../../../core/enums/industry.dart';
import '../api.dart';
import '../dynamicForms/dynamicFormContact.dart';
import '../dynamicForms/dynamicFormExternalItem.dart';

class TrendCreationDTO extends StatefulWidget {
  TrendCreationDTO({Key? key, required this.userToken}) : super(key: key);
  String userToken;
  @override
  State<StatefulWidget> createState() => _TrendCreationDTO();
}

class _TrendCreationDTO extends State<TrendCreationDTO> {
  //coreFields
  bool isIntern = false;
  TextEditingController source = TextEditingController();
  TextEditingController imageSource = TextEditingController();
  TextEditingController headline = TextEditingController();
  TextEditingController teaser = TextEditingController();
  late List<String> industries;
  String chosenIndustry = " ";
  TextfieldTagsController? tags = TextfieldTagsController();

  //detailed rating
  double degreeOfInnovation = 0;
  double disruptionPotential = 0;
  double useCase = 0;

  //required
  TextEditingController description = TextEditingController();
  TextEditingController discussion = TextEditingController();

  //company optional
  //external item
  List<String> type = ["Company", "Trend", "Technology", "Projects"];
  String chosenType = " ";
  TextEditingController text = TextEditingController();

  //contact
  var nameContact = <TextEditingController>[];
  var emailContact = <TextEditingController>[];
  var telephoneContact = <TextEditingController>[];
  var organisationContact = <TextEditingController>[];
  var cardsContact = <Card>[];
  List<Contact> contact = [];

  //external item
  var chosenTypeExternalItems = <TextEditingController>[];
  var textExternalItems = <TextEditingController>[];
  var cardsExternalItems = <Card>[];
  List<ExternalItems> externalItems = [];

  late Future<List<dynamic>> internalTechnologies =
      InternalApi.internalTechnologies;
  List<String> chosenInternalTechnologies = [];

  late Future<List<dynamic>> internalProjects = InternalApi.internalProjects;
  List<String> chosenInternalProjects = [];

  late Future<List<dynamic>> internalTrends = InternalApi.internalTrends;
  List<String> chosenInternalTrends = [];

  late Future<List<dynamic>> internalCompanies = InternalApi.internalCompanies;
  List<String> chosenInternalCompanies = [];

  @override
  void initState() {
    super.initState();
    industries = IndustryString.getIndustryString();
    industries.sort((a, b) => a.toString().compareTo(b.toString()));
  }

  /// It creates a form with a bunch of TextFields, DropDownMenus, RadioBoxes,
  /// TagFields, RatingBars and Buttons
  ///
  /// Args:
  ///   context (BuildContext): The BuildContext of the widget that includes the
  /// form.
  ///
  /// Returns:
  ///   A Widget
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// coreFields
        TextLabel.addTextLabel("Erforderlich *"),
        TextLabel.addTextLabel("Intern"),
        RadioBox(
          optionOne: "Ja",
          optionTwo: "Nein",
          groupValue: isIntern,
          valueOne: true,
          valueTwo: false,
          onChanged: (newValue) {
            setState(
              () {
                isIntern = newValue!;
                print(isIntern);
              },
            );
          },
        ),
        DTOTextField(controller: source, label: 'Quelle *'),
        DTOTextField(controller: imageSource, label: 'Link zum Bild *'),

        DTOTextField(controller: headline, label: 'Überschrift *'),
        DTOTextFieldExpanded(controller: teaser, label: 'Zusammenfassung *'),
        DropDownMenu(
            dropDownList: industries,
            onChanged: (String? newValue) => setState(
                  () {
                    chosenIndustry = newValue!;
                  },
                ),
            label: 'Wähle eine Industrie aus *'),

        TagField(controller: tags, label: 'Stichwörter / Buzzwörter *'),

        ///rating
        RatingBarStar(
            onRatingUpdate: (double value) {
              setState(
                () {
                  degreeOfInnovation = value;
                },
              );
            },
            label: "Grad der Innovation *"),
        RatingBarStar(
            onRatingUpdate: (double value) {
              setState(
                () {
                  disruptionPotential = value;
                },
              );
            },
            label: "Bewertung des Störungspotenzials *"),
        RatingBarStar(
            onRatingUpdate: (double value) {
              setState(
                () {
                  useCase = value;
                },
              );
            },
            label: "Bewertung des Anwendungsfalls *"),

        ///company required
        DTOTextFieldExpanded(controller: description, label: "Beschreibung *"),
        DTOTextFieldExpanded(
            controller: discussion, label: "Vor- und Nachteile *"),

        ///optional
        ///optional
        /// externalItems
        TextLabel.addTextLabel("Externe Elemente"),
        FixedPadding.addPaddingWidget(
          ElevatedButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [Icon(Icons.add), Text('Hinzufügen')],
            ),
            onPressed: () async {
              externalItems = await Navigator.push(
                context,
                MaterialPageRoute(
                  maintainState: true,
                  builder: (context) => DynamicFormExternalItem(
                      chosenType: chosenTypeExternalItems,
                      text: textExternalItems,
                      cards: cardsExternalItems,
                      title: "externe Elemente"),
                ),
              );
            },
          ),
        ),

        /// contacts
        TextLabel.addTextLabel("Kontakt"),

        FixedPadding.addPaddingWidget(
          ElevatedButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [Icon(Icons.add), Text('Hinzufügen')],
            ),
            onPressed: () async {
              contact = await Navigator.push(
                context,
                MaterialPageRoute(
                  maintainState: true,
                  builder: (context) => DynamicFormContact(
                      name: nameContact,
                      email: emailContact,
                      telephone: telephoneContact,
                      organisation: organisationContact,
                      cards: cardsContact,
                      title: "Neue Kontakte"),
                ),
              );
            },
          ),
        ),

        ///industriesWithUse
        FixedPadding.addPadding(),
        MultiDropDownPostRequest(
            internalIdeas: internalTechnologies,
            onChanged: (List<String> values) {
              setState(
                () {
                  chosenInternalTechnologies = values;
                },
              );
            },
            chosenElements: chosenInternalTechnologies,
            label: 'Wähle verknüpfte interne Technologien aus'),
        MultiDropDownPostRequest(
            internalIdeas: internalTrends,
            chosenElements: chosenInternalTrends,
            onChanged: (List<String> values) {
              setState(
                () {
                  chosenInternalTrends = values;
                },
              );
            },
            label: 'Wähle verknüpfte interne Trends aus'),
        MultiDropDownPostRequest(
            internalIdeas: internalCompanies,
            chosenElements: chosenInternalCompanies,
            onChanged: (List<String> values) {
              setState(
                () {
                  chosenInternalCompanies = values;
                },
              );
            },
            label: 'Wähle verknüpfte interne Unternehmen aus'),
        MultiDropDownPostRequest(
            internalIdeas: internalProjects,
            chosenElements: chosenInternalProjects,
            onChanged: (List<String> values) {
              setState(
                () {
                  chosenInternalProjects = values;
                },
              );
            },
            label: 'Wähle verknüpfte interne Projekte aus'),
        SubmitButton(
            label: "Submit",
            onPressMethod: () async {
              if (checkIfRequiredFilled()) {
                await InternalApi.postDTO("http://localhost:8080/api/v2/trend/",
                        createBodyMap(), widget.userToken)
                    .then((value) {
                  print("calue : $value");
                  if (value == true) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text("Objekt wurde erfolgreich erstellt")));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(
                            "Es ist ein Fehler aufgetreten. Füllen Sie alle Felder mit * aus und versuchen Sie es erneut")));
                  }
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    backgroundColor: Colors.amber,
                    content:
                        Text("Fülle alle erforderlichen (*) Felder aus ")));
              }
            })
      ],
    );
  }

  /// It creates a map of the data that is entered in the form
  ///
  /// Returns:
  ///   A map of the body of the request.
  Future<Map<String, dynamic>> createBodyMap() async {
    List<int> internalProjectsID = await InternalApi.getIdFromHeadline(
        chosenInternalProjects, internalProjects);
    List<int> internalTrendsID = await InternalApi.getIdFromHeadline(
        chosenInternalTrends, internalTrends);
    List<int> internalTechnologiesID = await InternalApi.getIdFromHeadline(
        chosenInternalTechnologies, internalTechnologies);
    List<int> internalCompaniesID = await InternalApi.getIdFromHeadline(
        chosenInternalCompanies, internalCompanies);

    Map<String, dynamic> mapBody = {
      'coreField': {
        'intern': isIntern,
        'source': source.text,
        'imageSource': imageSource.text,
        'headline': headline.text,
        'teaser': teaser.text,
        'industry': EnumUtil.StringToEnumStringIndustry(chosenIndustry),
        'tags': tags!.getTags,
        'type': "TREND"
      },
      "trendRequired": {
        "description": description.text,
        "discussion": description.text,
      },
      "detailedRating": {
        "degreeOfInnovation": degreeOfInnovation,
        "disruptionPotential": disruptionPotential,
        "useCases": useCase
      },
      "trendOptionalCreation": {
        "externalProjects": [],
        "contacts": [],
      },
      "internalProjects": internalProjectsID,
      "internalTrends": internalTrendsID,
      "internalTechnologies": internalTechnologiesID,
      "internalCompany": internalCompaniesID
    };
    var mapContact = mapBody["trendOptionalCreation"]["contacts"];
    for (int i = 0; i < cardsContact.length; i++) {
      Map<String, String> contact = {};
      String name = nameContact[i].text;
      String email = emailContact[i].text;
      String telephone = telephoneContact[i].text;
      String organisation = organisationContact[i].text;
      if ((name != "" || name.isNotEmpty) &&
          (email != "" || email.isNotEmpty) &&
          (telephone != "" || telephone.isNotEmpty) &&
          (organisation != "" || organisation.isNotEmpty)) {
        contact["name"] = name;
        contact["email"] = email;
        contact["telephone"] = telephone;
        contact["organisation"] = organisation;
      }
      if (contact.isNotEmpty) {
        mapContact.add(contact);
      }
    }
    var mapExternalItem = mapBody["trendOptionalCreation"]["externalProjects"];
    for (int i = 0; i < cardsExternalItems.length; i++) {
      Map<String, String> externalItem = {};
      String chosenType = chosenTypeExternalItems[i].text;
      String text = textExternalItems[i].text;
      if ((chosenType != "" || chosenType.isNotEmpty) &&
          (text != "" || text.isNotEmpty)) {
        externalItem["type"] = chosenType;
        externalItem["text"] = text;
      }
      if (externalItem.isNotEmpty) {
        mapExternalItem.add(externalItem);
      }
    }
    print(mapBody);
    return mapBody;
  }

  /// If any of the required fields are empty, return false
  ///
  /// Returns:
  ///   A boolean value.
  bool checkIfRequiredFilled() {
    if (imageSource.text.isEmpty ||
        headline.text.isEmpty ||
        teaser.text.isEmpty ||
        chosenIndustry.isEmpty ||
        !tags!.hasTags ||
        degreeOfInnovation == 0 ||
        disruptionPotential == 0 ||
        useCase == 0 ||
        description.text.isEmpty ||
        discussion.text.isEmpty) {
      return false;
    }
    return true;
  }
}
