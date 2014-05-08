Aware 
Aware signalerar för din användare att vi inte tar hand om vår kund så som våra kärnvärden utlovar!
 Missa aldrig:
-       att dina supportärenden dragit över tiden
-       att din kund inte fått den uppmärksamhet de förtjänar
-       att fylla information du behöver för att göra ett bra jobb!
 Bakgrund:
Visst har det hänt mer än en gång att du missat att återkomma till kunder som har problem. Aware lyfter på ett sinnrikt sätt fram för din användare att de problem kunden flaggat för inte åtgärdats som utlovat. 
Eftersom du är en framgångsrik krösus så får inte ens dina viktiga kunder den uppmärksamhet de förtjänar. Visst borde du ringa dina kunder oftare än vart tredje år...
Vi kan inte be om ursäkt åt dig, men vi kan tala om när det är dags att be om ursäkt! För sjutton, vi ger dig till och med ursäkten och försoningsgåvan med ett knapptryck!
 För att vi alltid ska kunna kontakta våra kunder och ge dem den uppmärksamhet de förtjänar låter vi även Aware påminna dig om att du från tid till annan inte fyllt i all info du borde. Kort och gott visar Aware hur stor del av dina viktiga fält du fyllt i. 100% ifyllnad ger grönt ljus, hur det går annars kommer du inte missa.
 Pitch!
Aware to take care!
 
Kundreferens:
Aware är utan tvekan en av de mest uppskattade företagsapparna på Securitas. 
”Utan Aware skulle vi aldrig kunna visa så fina siffror i våra kundnöjdhetsmätningar. Innan vi införde Aware hände det då och då att kunder inte kontaktades som utlovat. Än värre bad vi inte om ursäkt eftersom vi inte uppmärksammandes på att vi glömt kunden. 
Nu uppmärksammas vi omgående och kan enkelt be om ursäkt. Att be om ursäkt är utomordentligt uppskattat av våra kunder och som det gamla ordspråket säger, övning ger färdighet” säger Kristoffer Sakaria, CRM-ansvarig på Securitas.

Användning:
<div data-app="{app:'info',config:{
	icon1: 'fa-frown-o',
	icon2: 'fa-meh-o',
	icon3: 'fa-smile-o',
	text1: 'Gammal som gatan',
	text2: 'Inte så gammal',
	text3: '',
	dataSource: {
                    type:'xml',
                    source:'checkHistory.call_checkHistory,7,14'
                    , alias: 'aware'
                }
}}">
</div>


<div data-app="{app:'info',config:{
	icon1: 'fa-frown-o',
	icon2: 'fa-meh-o',
	icon3: 'fa-smile-o',
	text1: 'Flera obligatoriska fält ej ifyllda',
	text2: 'Ett par obligatoriska fält ej ifyllda',
	text3: 'Alla obligatoriska fält är ifyllda',
	dataSource: {
                    type:'xml',
                    source:'checkHistory.checkFields, name;phone;www'
                    , alias: 'aware'
                }
}}">
</div>
	

<div data-app="{app:'info',config:{
	icon1: 'fa-frown-o',
	icon2: 'fa-meh-o',
	icon3: 'fa-smile-o',
	text1: 'SOS-ärende finns',
	text2: '',
	text3: '',
	dataSource: {
                    type:'xml',
                    source:'checkHistory.call_checkHelpdesk'
                    , alias: 'aware'
                }
}}">
</div>