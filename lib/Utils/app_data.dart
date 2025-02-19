enum Environment { Prod, Dev }

const Environment currentEnv =
    Environment.Prod; //TODO changes razorpay & crashlytics

String get RazorPayKey =>
    currentEnv == Environment.Prod ? RazorPayKeyLive : RazorPayKeyTest;
const String RazorPayKeyLive = "rzp_live_LSqvL8ThZ5EBpZ";
const String RazorPayKeyTest = "rzp_test_A8147YHisgXGNt";
const String GoogleApiKey = 'AIzaSyC4aR_R7YDAs6OQ3WoIdXt90hyvu2tuLek';
const String rupeeSign = '₹';

class AppData {
  static const List<Map<String, String>> rentPayFAQs = [
    {
      'heading': 'What kind of rent payments can be done on Letzrent?',
      'body':
          'Via Rentpay feature on Letzrent you can make payments for your house rent, office rent, brokerage, security deposit, and taken amount.'
    },
    {
      'heading': 'Is it safe is to pay rent on Letzrent?',
      'body':
          'At Letzrent, your security is of paramount importance to us. We use advanced security technology to ensure your confidential information is secured.'
    },
    {
      'heading': 'What are the benefits of Rent pay through credit card?',
      'body':
          'At letzrent by paying your rent through credit card gives you a loads of benefit:\n- Earn Letzrent reward points and redeem it against Car, Aircrafts, Furniture, Appliances, Apparel & Yatch bookings. Upto a maximum of 500 Letzrent reward points can be redeemed in a single transaction.\n-Get up to 45 days credit free period from your credit card. Earn rewards on your credit card.\n-Reach your credit card annual fee waiver and reward milestone.'
    },
    {
      'heading': 'Are there any charge for using rentpay on Letzrent?',
      'body':
          'We charge a service fee of 1% to 3% to process your rent payment. This fees would be clearly mentioned on payment review screen before you initiate the payment.'
    },
    {
      'heading': 'How long it will take for my landlord to receive the amount?',
      'body':
          'Though it may take 2 business days, however majority of the transactions gets completed within couple of hours.'
    },
    {
      'heading': 'If my account gets debited but payment gets failed ?',
      'body':
          'That would a rare event however in such an event an automatic refund will be initiated and you will receive the money in 5-7 business days in your account.'
    },
    {
      'heading': 'Is landlord PAN mandatory?',
      'body':
          'For rent amount above INR 50,000/ its mandatory to provide the landlord PAN details.'
    },
  ];

  static const List<Map<String, String>> faqList = [
    {
      'What All Information Is Required From Me To Book A Car?':
          'You will need to enter:\n  Your name\n  Mobile number\n  Valid email address\n  Valid driving license\n  Aadhar\n  Address proof- Aadhar, utility bill, passport etc.'
    },
    {
      'Can Someone Else Make A Reservation For Me?':
          'Yes, but you need to be present with the required documents to pick up the car at the mentioned pickup location.'
    },
    {
      'Can Someone Else Drive For Me During My Reservation?':
          'Only the person whose KYC documents along with driving license are submitted while making the reservation can drive the vehicle.'
    },
    {
      'Is There A Minimum Booking Duration?':
          'Vendor wise minimum booking duration details are as follows: \nZoomCar – 6 Hours. \nWowCarz – 6 hours on Weekdays, 18 Hours on Weekend\nMyChoize – 24 Hours\nAVIS - 24 Hours'
    },
    {
      'Can I Prepone My Trip?':
          'Please contact our call centre, respective agent will be able to inform you whether it’s possible or not'
    },
    {
      'How Many Hours In Advance Do I Need To Make A Reservation?':
          'You can book the car minimum 7 hours in advance, depending on the availability of the car.'
    },
    {
      'Can I Drop the Car to Any Other Location Than the Pickup Location':
          'None of the service provider allows you to drop the car at the different location.'
    },
    {
      "Do You Have a 24 * 7 Reservation at All Your Locations?":
          "You may book the vehicle at any time of the day either through the Zymo App. You can pick up/drop off the vehicle at any time from the given locations"
    },
    {
      "Can I Take A Pet Along With Me?":
          "Zoomcar, WOWcarz & Avis does not allow pets in the car. MyChoize allows you to take your pet along with you charge of INR 750 will be levied as additional for bringing the pets in the car"
    },
    {
      "What Type Of Driver’s License Is Required?":
          "We require an Indian driver's license or an International Driver's Permit (IDP). Our respective service providers /vendors will verify original license. The licenses must be for a light motor vehicle (car). The customers do NOT need a specific cab license that is associated with a yellow board plate"
    },
    {
      "Will I Be Allowed To Use a Car in Case I Fail To Produce the Original Documents at the Time of Pickup?":
          "No. You will not be allowed to rent the vehicle in case you fail to produce the original documents at the time of scheduled vehicle pickup. Besides, we reserve the right to forfeit 100% of your rental amount in such a scenario"
    },
    {
      "What Type of Cars Is Offered?":
          "It is advised to physically inspect the car and sign the checklist"
    },
    {
      "Does the Vehicle Have Manual or Automatic Transmission?":
          "You may check the vehicle's specifications for these details at the time of booking"
    },
    {
      "What Are the Amenities You Provide with Your Car?":
          "All cars are equipped with manufacturer’s standard car accessories"
    },
    {
      "Is Smoking Allowed in Car?": "Smoking is strictly not allowed in the car"
    },
    {
      "Do I Need to Clean the Car?":
          "Unclean cars may attract cleaning charge of INR 750 for a minor cleaning & a charge of INR 1250 for a major cleaning as penalty"
    },
    {
      "What Mode of Payments Are Accepted?":
          "Payments by credit cards (visa/master card), UPI and net banking. All rental payments are made in advance through our website or mobile app"
    },
    {
      "Are There Any Taxes on the Rental Amount?":
          "Yes, GST will be applicable as per the state laws"
    },
    {
      "Are There Any Taxes on the Incidental Charges?":
          "Any incidental charges to main services will be included in the value of taxable supply for the purpose of charge of GST. Toll, Parking, Challans etc. are incidental charges to the main activity of rent a car and therefore it is chargeable to GST. Extract from The Central Goods and Services Tax Act, Section 15 for reference. Value of taxable supply 15(1) The value of a supply of goods or services or both shall be the transaction value, which is the price actually paid or payable for the said supply of goods or services or both where the supplier and the recipient of the supply are not related and the price is the sole consideration for the supply. (2) The value of supply shall include___ (c) incidental expenses, including commission and packing, charged by the supplier to the recipient of a supply and any amount charged for anything done by the supplier in respect of the supply of goods or services or both at the time of: or before delivery of goods or supply of services."
    },
    {
      "Is Security Deposit Different for Different Car Model?":
          "Yes, some cars may attract a higher security deposit, however it’s an exception only as mostly security deposit is dependent on vendor selected not on car"
    },
    {
      "How Will You Refund My Security Deposit?":
          "We will refund your Security Deposit to the source of payment, which may be your credit card or bank, whichever you used at the time of booking. And according to once the booking gets completed, we will process the refund of your security deposit within 8-10 working days. The payment owed will be deducted from the security deposit in the event the customer is found to violate T&C"
    },
    {
      "When Will I Get My Refund Back?":
          "It usually takes 7-10 working days for your bank to credit the same into your account"
    },
    {
      "Will I Get a Physical Bill?":
          "The copy of the invoice will be mailed to you on your registered e-mail ID"
    },
    {
      "Do I Have to Return the Car to the Same Location Where I Picked It Up":
          "Yes. You must bring the vehicle back to the same place you picked it up before the end of your reservation"
    },
    {
      "What Happens If I Return the Car Late?":
          "A high penalty will be applicable for the amount of time you are late. In order to avoid paying this penalty, book with some buffer time in hand"
    },
    {
      "Is There a KM Limit to How Much I Can Drive?":
          "You can drive up to the package selected at the time of booking. For driving beyond the free kms of the package taken, fine and penalty may be charged in addition to the per km rate"
    },
    {
      "In Case of Doorstep Service Who Will Deliver the Car?":
          "A delivery executive will be allotted for your booking one hour before the booking start time, you will receive the details of the delivery executive at the same time. In the case of address clarification, our executive will call you for confirmation and he will be at your location by your bookings start time. You can contact the executive over the shared contact number"
    },
    {
      "How Do I Reach the Location of the Car?":
          "Once the booking is confirmed, vehicle details with the location would be shared 3-4 hours prior to booking start time"
    },
    {
      "What If I See There Are Exterior Damages on the Vehicle?":
          "We try to inspect all our vehicle's condition periodically however if you notice any damage on the vehicle, Please do call out the same and also do capture the images for future reference"
    },
    {
      "What If There Is an Outstanding Amount Against My Previous Booking Pending?":
          "You will not be able to pick up the vehicle on your next booking unless you have cleared all the outstanding balance from your previous booking. Please ensure you check for pending outstanding before making another booking"
    },
    {
      "When Will I Get to Know the Exact Vehicle Details?":
          "Vehicle and Location details would be shared 3-4 hours prior to your booking start time to your registered mobile number"
    },
    {
      "What Is Traffic Violation Fee?":
          "Please ensure you drive safely without breaking any traffic rules. In case of an uncertain event of a traffic violation, Please clear the penalty through the Govt portal to avoid un-necessary charges against your booking and inconvenience to other customers"
    },
    {
      "Will I Be Charged for the Cancellation of the Booking?":
          "a) A cancellation charge of Rs200 applies if you cancel more than 24 hours before booking start time. b) A charge of 50% of the booking amount is applicable if canceled within 24 hours of the booking start time. c) No cancellation is allowed after booking start time as there is no refund."
    },
    {
      "How Old Do I Need To Be To Rent A Car?":
          "ZoomCar &amp; AVIS – Minimum 18 Years Mychoize &amp; WowCarz – Minimum 21 Years"
    },
    {
      "What Fuel Types Are Available in Cars?":
          "For self-drive, we have diesel/petrol/electric cars in our fleet"
    },
    {
      "What Is The Fuel Policy?":
          "The car will be delivered with a certain level in full tank and need to be returned at the same level. Customer pays for the fuel charges based on the usage. If the car is returned with less than full tank fuel, Vendor will charge for the differential fuel. The customer can either pay this directly by cash/card at the time of car pick up or the same will be deducted from the security deposit. The assessment made by the Vendor on the differential fuel amount will be final."
    }
  ];

  static const List<Map<String, String>> allCategories = [
    {
      'title': 'Self Drive Cars',
      'image': 'assets/images/Tips&Tricks/self_drive.jpg',
      'url': 'https://letzrent.com/self-drive-car-for-rent/'
    },
    {
      'title': 'Monthly Car Rental',
      'image': 'assets/images/Tips&Tricks/monthly_rental.jpg',
      'url':
          'https://letzrent.medium.com/10-tips-for-furniture-rental-b54fd12fd528'
    }
  ];

  static const Categories = [
    'Self Drive Cars',
    'Monthly Car Rental',
  ];
}
