// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
try{jQuery.noConflict();}catch(e){};

function addImageField(){
	if (jQuery('#listing_image_fields p').length < 6) {
		var f = jQuery('#listing_image_tag').clone();
		f.find('input').attr('value', '');
		jQuery('#listing_image_fields').append(f);
	}else{alert('You can add maximum of 6 pictures');}
}

function removeImageField(me){
	if (jQuery('#listing_image_fields p').length > 1) {
		me.parentNode.parentNode.removeChild(me.parentNode);
	}else{alert('You can not remove all image fields');}
}