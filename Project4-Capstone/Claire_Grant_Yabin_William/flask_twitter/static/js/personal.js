/**
 * Created by Jingmei on 16/10/20.
 */
/*
$.post("/gmap", function(data){
    result=JSON.parse(data);
    alert(result["a"]);
});
*/

var n = [
  {lat: 52.511, lng: 13.447},
  {lat: 52.549, lng: 13.422},
  {lat: 52.497, lng: 13.396},
  {lat: 52.517, lng: 13.394}
];

var markers = [];
var map;
var latitude=0;
var longitude=0;

function initMap() {
   map = new google.maps.Map(document.getElementById('map'), {
             zoom: 5,
             center: {lat: 40.730610, lng: -73.935242}
        });
    google.maps.event.addListener(map, "click", function (event) {
        clearMarkers();
    latitude = event.latLng.lat();
    longitude = event.latLng.lng();
        $.post("/w/"+latitude+'_'+longitude, function(data){
            console.log('success')
        });
        var marker = new google.maps.Marker({
                    position: {lat: latitude, lng: longitude},
                    map: map
                })
                markers.push(marker)
    });
}

function drop(value) {
    clearMarkers();
    var res=[];
    $.get("/q/"+value, function(data){
            tmp=JSON.parse(data);
            res.push(tmp.a)
        //console.log(res[0])
            res=res[0]
        //console.log(res.length)
            for (var i = 0; i < res.length; i++) {
                    var marker = new google.maps.Marker({
                        position: {lat: res[i]['geo'][1], lng: res[i]['geo'][0]},
                        map: map
                    })
                    markers.push(marker)
                    var infowindow = new google.maps.InfoWindow( {maxWidth: 200})
                    var content=res[i]['text']
                    //var content=res[i]['user']+'</br>'+res[i]['text']
                    google.maps.event.addListener(marker, 'click', (function (marker, content, infowindow) {
                        return function () {
                            infowindow.setContent(content);
                            infowindow.open(map, marker);
                        };
                    })(marker, content, infowindow));
                }


       /*
            for (var i = 0; i < n.length; i++) {
                var marker = new google.maps.Marker({
                    position: n[i],
                    map: map
                })
                markers.push(marker)
                var infowindow = new google.maps.InfoWindow()
                var content='hi'+'</br>'+'ni'
                google.maps.event.addListener(marker, 'click', (function (marker, content, infowindow) {
                    return function () {
                        infowindow.setContent(content);
                        infowindow.open(map, marker);
                    };
                })(marker, content, infowindow));
            }
        */
        });

}

function clearMarkers() {
  for (var i = 0; i < markers.length; i++) {
    markers[i].setMap(null);
  }
  markers = [];
}
