//获取各类型成果
function getArticles(obj, types) {
    filterquery = "";
    filterquery_list = "";
    if(types == 'Conference') {
    	//会议论文
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=Conference&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=Conference&filtertype=equals";
	} else if(types == 'Book') {
		//专著 
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=Book&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=Book&filtertype=equals";
	} else if(types == 'Journal') {
		//期刊论文
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=Journal&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=Journal&filtertype=equals";
	} else if(types == 'Thesis') {
		//学位论文
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=Thesis&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=Thesis&filtertype=equals";
	} else if(types == 'kyxm') {
		//科研项目
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=kyxm&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=kyxm&filtertype=equals";
	} 
	else if(types == 'Patent') {
		//专利
		filterquery = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=type&filterquery=Patent&filtertype=equals";
		filterquery_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=type&filterquery=Patent&filtertype=equals";
	}

    $.ajax({
        url: "../"+filterquery+"&cgfl=1",
        success: function (data) {
        	document.getElementById("cgfl_more").href = filterquery_list;
            $("#article_list").html(data);
            $(obj).siblings().removeClass("current_sl");
            $(obj).addClass("current_sl");
        }
    });
}
//获取被收录情况
function getArticles_sl(obj, types) {
    filterquery_sl = "";
    filterquery_sl_list = "";
    if(types == 'SCI-E') {
    	//会议论文
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=SCI-E&filtertype=equals";
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=SCI-E&filtertype=equals";
	} else if(types == 'SCI') {
		//专著 
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=SCI&filtertype=equals";
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=SCI&filtertype=equals";
	} else if(types == 'EI') {
		//期刊论文
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=EI&filtertype=equals";	
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=EI&filtertype=equals";
	} else if(types == 'CPCI-S') {
		//期刊论文
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=CPCI-S&filtertype=equals";
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=CPCI-S&filtertype=equals";
	} else if(types == 'CPCI-SSH') {
		//期刊论文
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=CPCI-SSH&filtertype=equals";
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=CPCI-SSH&filtertype=equals";	
	} else if(types == 'CSCD') {
		//学位论文
		filterquery_sl = "simple-search?query=&sort_by=score&order=desc&rpp=10&etal=0&filtername=indexed&filterquery=CSCD&filtertype=equals";
		//此处改为20后报错   rpp=10
		filterquery_sl_list = "simple-search?query=&sort_by=score&order=desc&rpp=20&etal=0&filtername=indexed&filterquery=CSCD&filtertype=equals";
	}
    $.ajax({
        url: "../"+filterquery_sl+"&cgfl=1",
        success: function (data) {
        	document.getElementById("cgfl_more_sl").href = filterquery_sl_list;
            $("#article_list_sl").html(data);
            $(obj).siblings().removeClass("current_sl");
            $(obj).addClass("current_sl");
        }
    });
}
//学者推荐
function get_xztj() {
	filterquery_xztj = "../researcher-orderlist";
    $.ajax({  
      url: "../"+filterquery_xztj,
	  dataType:"json",       
      success: function (json) {
       	// alert(json.researcherList[0]['unitId']);
  		var list = json["researcherList"];
  		// alert(list[0].unitId);
		// var a = typeof json;
		str_div = '';
		if(list.length >= 9) {
			for(var xz = 0; xz < 9; xz++) {
				if(xz%3==0) {
				  str_div += '<div class="row" style="margin-top: 20px;padding-left:25px">';
				}	
				str_div += '<div class="col-md-3 text_w" >';
				str_div += '<a href="/researcher?id='+list[xz].researcherId+'&uid='+list[xz].uid+'&fullname='+list[xz].name+'" target="_blank"><div class="pic-home-wrap"><img class="pic-home" src="'+list[xz].image+'"></div></a>';
				str_div += '<div class="pic-home-text arrow-left-1" style= "padding-left:100px;width:180px;" >';
				str_div += '<p><span class="title"></span></p><p><span class="name">'+list[xz].name+'</span></p><p><span class="unit">'+list[xz].unitId+'</span></p>';
				str_div += '</div>';
				str_div += '</div>';
				if(xz%3==2) {
				//out.print(xz%3);
					str_div +='</div><div style="clear: both"></div>';
				}
			}
		}
		// console.log(a);
		// console.log(list);
		// console.log(str_div);
        $("#xztj_block").html(str_div);
     }
    });
}
