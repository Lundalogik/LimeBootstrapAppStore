#  Data flow #

CREATED BY: Tommy

##About
Shows some sort of data (for example history or todo) in a nice flow

###History
```html
<div data-app="{app:'Data flow', config:{
    tableStructure: {
        pageSize: 5,                                // How many objects to show
        tableName: 'history',                       // What table to show data flows from
        titleFieldName: 'type',                     // The title to show (Gets text value)
        typeFieldName: 'type',                      // The title to show (Gets key value if option otherwise it takes the text value, this also is used to choose the icon)
        dateFieldName: 'date',                      // The time field field to show
        relationFieldName: 'company',               // What field is the relation to the AP you're on
        noteFieldName: 'note',                      // The text to be shown in the flow
        clickableRelationFieldName: 'person'        // What field to be displayed as 'person' (Will create clickable link)
    },
    defaultIcon: 'fa-comment-o',                    // Default icon if no match in typeMapping
    typeMapping: {                                  // format: <typeKey>: <fa-icon> i.e. 'comment': 'fa-comment-o' will make the the if the key on the option is comment the icon will be 'fa-comment-o'
        'comment': 'fa-comment-o',
        'customervisit': 'fa-group',
        'noanswer': 'fa-thumbs-o-down',
        'receivedemail': 'fa-envelope-o',
        'salescall': 'fa-money',
        'sentemail': 'fa-paper-plane-o',
        'talkedto': 'fa-phone'
    },
    // Key for choosing what filter to use in the VBA module 'DataFlow', the function is called: 'GetFilterByKey'
    // The row below is commented out because usually you don't need it.
    // filterKey: 'company_history'                    // Make sure that what you choose here is mathced by the value in the Case-statement in the VBA. (DataFlow.GetFilterByKey)
}}"></div>

```