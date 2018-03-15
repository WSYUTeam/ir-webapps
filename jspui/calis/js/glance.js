$(function () {
	 var aj = $.ajax({    
 	    url:context + '/glance',
 	    type:'get',    
 	    cache:true,    
 	    dataType:'json',    
 	    success:function(data) {
 	    	if(data!=null){
 	    		$('#metadata .number').empty();
 	    		$('#metadata .number').append(data.metadata);
 	    		
 	    		$('#year .number').empty();
 	    		$('#year .number').append(data.year.oldest + "-" + data.year.newest);
 	    		
 	    		$('#fulltext .number').empty();
 	    		$('#fulltext .number').append(data.fulltext);
 	    		
 	    		$('#authors .number').empty();
 	    		$('#authors .number').append(data.author);
 	    		
 	    		$('#downloads .number').empty();
 	    		$('#downloads .number').append(data.download);
 	    		
 	    		$('#views .number').empty();
 	    		$('#views .number').append(data.views);
 	    	}
 	    }
	 });
});