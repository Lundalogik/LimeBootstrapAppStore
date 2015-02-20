#Yo!
##Info
Yo! allows you to ask questions and provide information to all you fellow LIME Pro users through the LIME Pro Actionpad.

Ask a question
Whether you need a quick answer to how many will join the after work on Friday, or what your colleagues think about the new structure of the Company card in LIME Pro, Yo! can help you. The questions will be shown in the Actionpad and all users will be able to answer with a simple click. 
Provide information
Provide your colleagues with information that needs to be shared. Everything from software updates to fika-rules. It’s all up to your imagination, and it’s easy peasy!
So what are you waiting for? Install the app, inform you colleagues how it works by providing information through Yo! and start a new era of easy communication!
</ul>

##Install
Copy the "Yo" folder to the "apps" folder. 

Create a VBA module called "Yo" and add the .bas file from the "/install" folder (drag n drop of the .bas file works well)

####LISA
Add the tables (name/display name en_us singular/display name plural/descriptive expression/icon name (o-collection)
<li>question/Question/Questions/[question].[text]/Question</li>
<li>answer/Answer/Answers/(select [name] from [coworker] where idcoworker = [answer].[coworker])  + ' - ' + [answer].[answer]/About</li>


Add fields (type/Length/name/English):

Table Question:
<li>Text field/256/text/Text</li>
<li>Time field (Date and time)//showfrom/Show from</li>
<li>Time field (Date and time//showto/Show to</li>
<li>Option//type/Type, With alternatives (option/option key), Freetext question/freetext, Information/information, Yes/No question yesno</li>
<li>“Yes/No field”//urgent/Urgent</li>
<li>Option//range/Show for, With alternatives (option/option key), My Office/my, All offices/all</li>

Table Answer:
<li>Relation//question/Question</li>
<li>Relation//coworker/Coworker</li>
<li>Text/256/answer/Answer</li>

 
####HTML
Add the following code to the `index.html`:
    
	<div data-app="{app:'Yo', config:{}}"></div>
