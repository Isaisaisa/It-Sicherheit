!function(e){"object"==typeof module&&module.exports?module.exports=e:"function"==typeof require&&require.amd?require(["password_strength","jquery"],e):e(window.PasswordStrength,window.jQuery)}(function(e,t){t.strength=function(s,n,r,a){"function"==typeof r?(a=r,r={}):r||(r={});var o=t(s),g=t(n),u=new e;u.exclude=r.exclude,a=a||t.strength.callback;var d=function(){u.username=t(o).val(),0==t(o).length&&(u.username=s),u.password=t(g).val(),0==t(g).length&&(u.password=n),u.test(),a(o,g,u)};t(o).keydown(d),t(o).keyup(d),t(g).keydown(d),t(g).keyup(d)},t.extend(t.strength,{callback:function(e,s,n){var r=t(s).next("img.strength");r.length||(t(s).after("<img class='strength'>"),r=t("img.strength")),t(r).removeClass("weak").removeClass("good").removeClass("strong").addClass(n.status).attr("src",t.strength[n.status+"Image"])},weakImage:"/images/weak.png",goodImage:"/images/good.png",strongImage:"/images/strong.png"})});