(function ($, window) {    
    $.fn.contextMenu = function (idOfTarget, activity) {        
        return this.each(function () {            
            // Open context menu
            $(this).on("contextmenu", function (e) {
                $('#ignore').text('');
                $('#special').text('');
                $('#history').text('');
                $('#ongoing').text('');

                $('#ongoing').append(' <i class="fa fa-gears"> </i>');                
                $('#history').append(' <i class="fa fa-pencil"> </i>');
                $('#history').append('Skapa historik');
                
                $('#ignore').append(' <i class="fa fa-times"> </i>');
                if (activity.ignore == 1) {                    
                    $('#ignore').append(' Avignorera');                    
                }
                else {
                    $('#ignore').append(' Ignorera');
                }
                if (activity.activateadvance == 1) {
                    $('#specialHolder').css('visibility', 'visible');
                    if (activity.document != null) {
                        $('#special').append(' <i class="fa fa-file-o"> </i>');
                        $('#special').append('  &Ouml;ppna ' + activity.document);                        
                    }
                }
                else {                    
                    $('#special').text('');
                    $('#specialHolder').css('visibility', 'hidden');
                }

                if (activity.ongoing == 1) {
                    $('#ongoing').append(' &Aring;teruppta');
                }
                else {
                    $('#ongoing').append('  Markera som p&aring;g&aring;ende');
                }
                //open menu
                $(idOfTarget)
                    .data("invokedOn", $(e.target))
                    .show(                    
                    )
                    .css({
                        position: "absolute",
                        left: getLeftLocation(e),
                        top: getTopLocation(e)
                    })
                    .off('click')
                    .on('click', function (e) {
                        $(this).hide();
                        if (e.target.id == "ignore") {                            
                            if ((activity.done == 0 || activity.ignore == 1)) {
                                
                                if (activity.hasoptions == 0){
                                    var ignore = activity.ignore == 1 ? 0 : 1;
                                    activity.ignoreActivity(ignore);
                                    activity.ignore = ignore;
                                    activity.ongoing = 0;
                                    activity.isOngoing(0);
                                    activity.check(activity);
                                }
                                else {
                                    var message = "Du kan inte ignorera denna aktiviteten.";
                                    alert(message);
                                }
                            }                            
                        }

                        if (e.target.id == "special") {
                            if (activity.activateadvance == 1) {
                                activity.special(activity);
                            }
                        }

                        if (e.target.id == "history") {
                            alert("Skapar historik");
                        }
                        if (e.target.id == "ongoing") {
                            if ((activity.done == 0 && activity.hasoptions == 0)) {
                                var ongoing = activity.ongoing == 1 ? 0 : 1;
                                activity.ongoing = ongoing;
                                activity.isOngoing(ongoing);
                            }
                            else {
                                var message = "Du kan inte markera denna punkt som ongoing.";
                                alert(message);
                            }
                        }
                });
                
                return false;
            });

            //make sure menu closes on any click
            $(document).click(function () {
                $(idOfTarget).hide();
            });
        });

        function getLeftLocation(e) {
            var mouseWidth = 30;
            var pageWidth = $(window).width();
            var menuWidth = $(idOfTarget).width()-200;
            
            // opening menu would pass the side of the page
            if (mouseWidth + menuWidth > pageWidth &&
                menuWidth < mouseWidth) {
                return mouseWidth - menuWidth;
            } 
            return mouseWidth;
        }        
        
        function getTopLocation(e) {
            var mouseHeight = e.pageY+11;
            var pageHeight = $(window).height();
            var menuHeight = $(idOfTarget).height();

            // opening menu would pass the bottom of the page
            if (mouseHeight + menuHeight > pageHeight &&
                menuHeight < mouseHeight) {
                return mouseHeight - menuHeight;
            } 
            return mouseHeight;
        }

    };
})(jQuery, window);