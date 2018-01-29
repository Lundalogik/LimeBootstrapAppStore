Pipeline
=========

Pipeline shows your Sales Pipe in the pretties way.


Info
----

This app shows you a sales pipe:

It sums up all values in each option in the status field and shows them in separat bars.
The percentage (and length) of each bar is the percentage of the total value of all bars together. ( So "current bar's value" / "All bar's value" )

You can click on an icon to show the active filter of the app in the main list.
You can also click on a specific bar, and that will take the active filter of the app and add a condition for that specific business status and show it in the main list.

Install
-----------

1. Copy “Pipeline” folder to the “apps” folder. 
2. Inside the Install folder you'll find a VBA Class called "PipelineClass" and a VBA module called "PipelineModule". Add them to your VBA-project.
3. Open the immediate window in VBA and Run the Command: "PipelineModule.Install" (This will add alla localization posts required)
4. Add the following HTML to the ActionPad and add configuration:

```html

<ul class="menu expandable">
    <li class="menu-header"data-bind="text:localize.Pipeline.header"></li> 
    <li class="divider"></li>
    <li>
        <div data-app="{app:'Pipeline', 
            config:{
                /* What table to fetch values from. Default: 'business' */
                table: 'business',

                /* What field to fetch statuses from. Default: 'businesstatus' */
                statusfield: 'businesstatus', 

                /* What field to fetch values from. Default: 'businessvalue' */
                valuefield: 'businessvalue',

                /* What field to fetch shadow values from ( A red line is shown to show like wheigted value vs. businessvalue) Default: No default value */
                valuefield: 'businessvalue',
                
                /* What currency are the value field in? Defult: 'tkr' */
                currency: 'kr', 
                
                /* What to divide the total value with? Defult: 1000 */
                divider: '1',
                
                /* How many decimals to show in each status. Default: '2' */
                decimals: '0',
                
                /* What thousand delimiter character to use. Default: ' ' */
                delimiterChar: ' ',

                /* What statuses should not be shown (;-seperated with ; in start and end of string) Default: <none> */
                excludeStatuses: ';rejection;onhold;',
                
                /*
                    What filters to show, an array with Objects.
                    The coloring of the bars is fetched from the color of that status (You can change it in LISA).
                */
                Filters: [
                    {    
                        /* If localize should be used as display name. (owner represents Owner field in Localize table and code represents the Text code field in Localize table) */
                        /* If you set localize to false or doesn't set it at all the display name will be the same as the Filter name */
                        
                        //localize: { owner: 'Pipeline', code: 'pipe' },
                        localize: false,

                        /* Name of the filter in LIME (Make sure the users have access to the filter) */
                        filter: 'Pipe' 
                    },
                    {    
                        localize: false,
                        filter: 'Min pipe'
                    },
                    /* Add as many filters as you want */
                ]
            }}">
        </div>
    </li>
</ul>