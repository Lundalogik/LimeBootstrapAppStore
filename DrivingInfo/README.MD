# Customer travel time pro exclusive premium master edition 2.0 (CTTPEPME) #
By Kamilla Svendsen (KSV), Vishal Ganatra (VGA), Olav Eidem (OEI) and An Thien Huynh (ATH)

This app to LIME PRO gives you instant access to information about your travel distance and time to your desired suspect, prospect or customer. 

## Installation
If this already exist then ignore

1. Add the “DrivingInfo” folder to the apps folder.
2. Create a VBA module by dragging the “DrivingInfo.bas”-file into VBA, or create a module and copy+paste the code
3. Insert the following html tag (look below) in the Company-actionpad (company.html)
4. Create two text-fields on the Company-card in LISA called “longitude” and “altitude”
5. Ceate a text-field on the office card called “address” (if it exist then ignore)
6. Create a text-field on the company card called “postaladdress1” (if it exist then ignore)
7. Compile the VBA, save it and restart LIME.

```html
  <div data-app=”{app:’DrivingInfo’, config:{}}”></div>
```

## How to use
### Requirements
- [x] All of the above
- [x] The current logged in user must be connected to an office (office-table)
- [x] The office that is connected to the current user must have an address 
- [x] The company you are opening must contain a postaladdress

## The real how to use guide
Open a company card
