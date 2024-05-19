import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:http/http.dart' as http; // Import the http package
import 'dart:convert';
import 'package:lab4_frontend/config.dart';

String selectedChargingPortsType= 'Type'; // Initial selected category
String selectedChargingWiresType= 'Type'; // Initial selected category
const List<String> chargingPortsType = <String>['USB', 'USB-C'];
const List<String> chargingWiresType = <String>['USB', 'USB-C', 'Micro USB', 'None'];
double? setheight = 4;

late double long;
late double lat;
late int cap;
late int cable;
String mUSB = "0";
String light = "0";
String uSBcc = "0";
String usBcP = "0";
String uSBp = "0";
String lockable = "0";

Map Add_Details = 
{
  "Longitude": long,
  "Latitude": lat,
  "Capacity": cap,
  "Have_cable": cable,
  "Micro_USB": mUSB,
  "Lightning": light,
  "USBC_Cable": uSBcc,
  "USBC_Port": usBcP,
  "USB_Port": uSBp,
  "Lockable": lockable
};

late int locationid;
late int capr;
late int cabler;
late String despr;
String reportt = "Damage";
String mUSBr = "0";
String lightr = "0";
String uSBccr = "0";
String usBcPr = "0";
String uSBpr = "0";
String lockabler = "0";

Map Report_Details =
{
  "LocationID": locationid,
  "Report_type": reportt,
  "New_Capacity": capr,
  "New_Have_cable": cabler,
  "Micro_USB": mUSBr,
  "Lightning": lightr,
  "USBC_Cable": uSBccr,
  "USBC_Port": usBcPr,
  "USB_Port": uSBpr,
  "Lockable": lockabler,
  "Description": despr
};

  Future<bool> addLocation() async { 

    final response = await http.post(
      Uri.parse('$ip/charging_location/add_location'), 
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
      body: jsonEncode(Add_Details)
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Added successfully M");
      return true;

    } else {
      // Registration failed
      debugPrint("Failed M");
      return false;
    }
  }

  Future<bool> reportLocation() async { 

    final response = await http.post(
      Uri.parse('$ip/charging_location/report_location'), 
      headers: {
      "Content-Type": "application/json", // Set the content type to JSON
      },
      body: jsonEncode(Report_Details)
    );

    if (response.statusCode == 200) {
      // Successful registration
      debugPrint("Report successfully M");
      return true;

    } else {
      // Registration failed
      debugPrint("Failed M");
      return false;
    }
  }

class ActivitesPage extends StatelessWidget {
  const ActivitesPage({super.key});

  @override
 Widget build(BuildContext context) {
  return const Scaffold(
    body: SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          ExpansionTile(
            title: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Discover new Charging location',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
            leading: Icon(Icons.charging_station),
            children: [
              Discover(),
            ],
          ),
          ExpansionTile(
            title: Text(
              'Report a Port',
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            leading: Icon(Icons.report_problem),
            children: [
              Report(),
            ],
          ),
        ],
      ),
    ),
  );
 }

}

//discover
class Discover extends StatefulWidget {
  const Discover({Key? key}) : super(key: key);

  @override
  _Discover createState() => _Discover();
}

class _Discover extends State<Discover> {

  final locationcontroller = TextEditingController();
  final capacitycontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: locationcontroller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter New Location',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: capacitycontroller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Capacity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Capacity must be a number';
                  }
                  return null; // Return null if the input is valid
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8), // Add vertical padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align checkboxes to the top
                      children: [
                        
                        PortCheckbox(),
                        Divider(height: 1, color: Color.fromARGB(255, 111, 102, 102)), // Add a divider line
                        WireCheckbox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: setheight), // Add space below the dropdown
           const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Lock(),
                  ),
                ),
              ),
            ),
          SizedBox(height: setheight),
          Align(
            alignment: Alignment.centerRight, // Set the desired alignment
            child: SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () 
                  async {
                    long = 103.6856; // Hard coded to hall 10 for now
                    lat = 1.3543;
                    cap = int.parse(capacitycontroller.text);
                    if (mUSB == "1" || light == "1" || uSBcc == "1")
                    {
                      cable = 1;
                    }
                    else
                    {
                      cable = 0;
                    }

                    bool success = await addLocation();
                    if (success) 
                    {
                      showSuccessfulPopUp(context);
                    }
                    else
                    {
                      showUnsuccessfulPopUp(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// report
class Report extends StatefulWidget {
  const Report({Key? key}) : super(key: key);

  @override
  _Report createState() => _Report();
}

class _Report extends State<Report> {

  final locationidcontroller = TextEditingController();
  final capacityreportcontroller = TextEditingController();
  final desciptioncontroller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: ReportType(),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: locationidcontroller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Location ID',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location ID';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Location ID must be a number';
                  }
                  return null; // Return null if the input is valid
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: capacityreportcontroller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Capacity',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Capacity must be a number';
                  }
                  return null; // Return null if the input is valid
                },
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8), 
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8), // Add vertical padding here
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align checkboxes to the top
                      children: [
                        PortCheckboxReport(),
                        Divider(height: 1, color: Color.fromARGB(255, 111, 102, 102)), // Add a divider line
                        WireCheckboxReport(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: setheight), // Add space below the dropdown
           const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LockReport(),
                  ),
                ),
              ),
            ),
          SizedBox(height: setheight),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: desciptioncontroller,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Enter Short Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short description';
                  }
                  return null;
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight, // Set the desired alignment
            child: SizedBox(
              width: 100,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ElevatedButton(
                  onPressed: () 
                  async 
                  {
                    locationid = int.parse(locationidcontroller.text);
                    capr = int.parse(capacityreportcontroller.text);
                    despr = desciptioncontroller.text;
                    if (mUSBr == "1" || lightr == "1" || uSBccr == "1")
                    {
                      cabler = 1;
                    }
                    else
                    {
                      cabler = 0;
                    }

                    bool successReport = await reportLocation();
                    if (successReport) 
                    {
                      // ignore: use_build_context_synchronously
                      showSuccessfulPopUp(context);
                    }
                    else
                    {
                      // ignore: use_build_context_synchronously
                      showUnsuccessfulPopUp(context);
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// widget for charging port types
class PortCheckbox extends StatefulWidget {
  const PortCheckbox({super.key});

  @override
  State<PortCheckbox> createState() => _PortCheckboxState();
}


class _PortCheckboxState extends State<PortCheckbox> {
  bool usb = false;
  bool usbc = false;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Port Types:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text('USB'),
          value: usb,
          onChanged: (value) {
            if (value == true)
            {
              uSBp = "1";
            }
            else
            {
              uSBp = "0";
            }
            setState(() {
              usb = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('USB-C'),
          value: usbc,
          onChanged: (value) {
            if (value == true)
            {
              usBcP = "1";
            }
            else
            {
              usBcP = "0";
            }
            setState(() {
              usbc = value!;
            });
          },
        ),
      ],
    );
  }
}



class WireCheckbox extends StatefulWidget {
  const WireCheckbox({super.key});

  @override
  State<WireCheckbox> createState() => _WireCheckboxState();
}

class _WireCheckboxState extends State<WireCheckbox> {
  bool microusb = false;
  bool usbc = false;
  bool lightning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Wire Types:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text('MicroUSB'),
          value: microusb,
          onChanged: (value) {
            if (value == true)
            {
              mUSB = "1";
            }
            else
            {
              mUSB = "0";
            }
            setState(() {
              microusb = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('USB-C'),
          value: usbc,
          onChanged: (value) {
            if (value == true)
            {
              uSBcc = "1";
            }
            else
            {
              uSBcc = "0";
            }
            setState(() {
              usbc = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Lightning'),
          value: lightning,
          onChanged: (value) {
            if (value == true)
            {
              light = "1";
            }
            else
            {
              light = "0";
            }
            setState(() {
              lightning = value!;
            });
          },
        ),
      ],
    );
  }
}


class PortCheckboxReport extends StatefulWidget {
  const PortCheckboxReport({super.key});

  @override
  State<PortCheckboxReport> createState() => _PortCheckboxStateReport();
}


class _PortCheckboxStateReport extends State<PortCheckboxReport> {
  bool usb = false;
  bool usbc = false;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Port Types:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text('USB'),
          value: usb,
          onChanged: (value) {
            if (value == true)
            {
              uSBpr = "1";
            }
            else
            {
              uSBpr = "0";
            }
            setState(() {
              usb = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('USB-C'),
          value: usbc,
          onChanged: (value) {
            if (value == true)
            {
              usBcPr = "1";
            }
            else
            {
              usBcPr = "0";
            }
            setState(() {
              usbc = value!;
            });
          },
        ),
      ],
    );
  }
}



class WireCheckboxReport extends StatefulWidget {
  const WireCheckboxReport({super.key});

  @override
  State<WireCheckboxReport> createState() => _WireCheckboxStateReport();
}

class _WireCheckboxStateReport extends State<WireCheckboxReport> {
  bool microusb = false;
  bool usbc = false;
  bool lightning = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            'Wire Types:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        CheckboxListTile(
          title: const Text('MicroUSB'),
          value: microusb,
          onChanged: (value) {
            if (value == true)
            {
              mUSBr = "1";
            }
            else
            {
              mUSBr = "0";
            }
            setState(() {
              microusb = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('USB-C'),
          value: usbc,
          onChanged: (value) {
            if (value == true)
            {
              uSBccr = "1";
            }
            else
            {
              uSBccr = "0";
            }
            setState(() {
              usbc = value!;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Lightning'),
          value: lightning,
          onChanged: (value) {
            if (value == true)
            {
              lightr = "1";
            }
            else
            {
              lightr = "0";
            }
            setState(() {
              lightning = value!;
            });
          },
        ),
      ],
    );
  }
}

// DROPDOWN widget for charging wire types 
/*
class DropdownMenuChargingWires extends StatefulWidget {
  const DropdownMenuChargingWires({super.key});

  @override
  State<DropdownMenuChargingWires> createState() => _DropdownMenuChargingWiresState();
}

class _DropdownMenuChargingWiresState extends State<DropdownMenuChargingWires> {
  String dropdownValue = chargingPortsType.first;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(0, -0.5),
      // will move the 'dropdownmenu' 50% of its width towards the left
      child: DropdownMenu<String>(
        hintText: 'Wire Type', // Set the initial text displayed before selection
        onSelected: (String? value) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = value!;
          });
        },
        dropdownMenuEntries: chargingWiresType.map<DropdownMenuEntry<String>>((String value) {
          return DropdownMenuEntry<String>(value: value, label: value);
        }).toList(),
      ),
    );
  }
}
*/



class Lock extends StatefulWidget {
  const Lock({Key? key}) : super(key: key);

  @override
  _Lock createState() => _Lock();
}

class _Lock extends State<Lock> {

  int currentToggleState = 0;

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: 90.0,
      cornerRadius: 20.0,
      activeBgColors: const [[Color.fromARGB(255, 5, 179, 179)], [Color.fromARGB(255, 7, 111, 114)]],
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      initialLabelIndex: currentToggleState,
      totalSwitches: 2,
      onToggle: (currentToggleState) {
        if (currentToggleState == 1)
        {
          lockable = "0";
        }
        if (currentToggleState == 0)
        {
          lockable = "1";
        }
        currentToggleState = currentToggleState!;
      },
      labels: const ['Lockable', 'Unlockable'],
      radiusStyle: true,
    );
  }
}

class LockReport extends StatefulWidget {
  const LockReport({Key? key}) : super(key: key);

  @override
  _LockReport createState() => _LockReport();
}

class _LockReport extends State<LockReport> {

  int currentToggleState = 0;

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: 90.0,
      cornerRadius: 20.0,
      activeBgColors: const [[Color.fromARGB(255, 5, 179, 179)], [Color.fromARGB(255, 7, 111, 114)]],
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      initialLabelIndex: currentToggleState,
      totalSwitches: 2,
      onToggle: (currentToggleState) {
        if (currentToggleState == 1)
        {
          lockabler = "0";
        }
        if (currentToggleState == 0)
        {
          lockabler = "1";
        }
        currentToggleState = currentToggleState!;
      },
      labels: const ['Lockable', 'Unlockable'],
      radiusStyle: true,
    );
  }
}

class ReportType extends StatefulWidget {
  const ReportType({Key? key}) : super(key: key);

  @override
  _ReportType createState() => _ReportType();
}

class _ReportType extends State<ReportType> {

  int currentReport = 0;

  @override
  Widget build(BuildContext context) {
    return ToggleSwitch(
      minWidth: 90.0,
      cornerRadius: 20.0,
      activeBgColors: const [[Color.fromARGB(255, 5, 179, 179)], [Color.fromARGB(255, 7, 111, 114)]],
      activeFgColor: Colors.white,
      inactiveBgColor: Colors.grey,
      inactiveFgColor: Colors.white,
      initialLabelIndex: currentReport,
      totalSwitches: 2,
      onToggle: (currentReport) {
        if (currentReport == 1)
        {
          reportt = "Incorrect";
        }
        if (currentReport == 0)
        {
          reportt = "Damage";
        }
        currentReport = currentReport!;
      },
      labels: const ['Damaged', 'Incorrect'],
      radiusStyle: true,
    );
  }
}

void showSuccessfulPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Thank you!'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.check_circle, // Tick icon
              color: Colors.green, // Icon color
              size: 48, // Icon size
            ),
            Text('Your submission has been received.'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Handle showing the damage report or navigating to the report page.
              // You can add navigation logic here.
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              // Close the dialog.
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

void showUnsuccessfulPopUp(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('There seems to be an error, please try again'),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              // Handle showing the damage report or navigating to the report page.
              // You can add navigation logic here.
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}