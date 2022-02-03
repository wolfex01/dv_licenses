let msgData
let typeData
let data

$(".box").draggable({ handle:'.header'});

window.addEventListener('message', function(event) {
    data = event.data
    if (data.action == 'show') {
        const showUI = document.querySelector('.box')
        $('.box').fadeIn();
        showUI.style.visibility = 'visible'
        document.getElementById("card").innerHTML = "$" + data.cardPrice;
        document.getElementById("license").innerHTML = "$" + data.driverPrice;
      }
  
    if (data.action == 'hide') {
        const hideUI = document.querySelector('.box')
        $('.box').fadeOut();
        hideUI.style.visibility = 'hidden'
    }
})

let driver = document.querySelector(".bottomDriver")
driver.addEventListener('click', () => {
    $('.box').fadeOut();
    $.post('http://dv_licenses/close')
    $.post(`http://dv_licenses/buy`, JSON.stringify({
      type: "DriverLicense",
      price: data.driverPrice
    })
  );
})

let idcard = document.querySelector(".bottomId")
idcard.addEventListener('click', () => {
    $('.box').fadeOut();
    $.post('http://dv_licenses/close')
    $.post(`http://dv_licenses/buy`, JSON.stringify({
      type: "CardLicense",
      price: data.cardPrice
    })
  );
})

let close = document.querySelector(".close")
close.addEventListener('click', () => {
    $('.box').fadeOut();
    $.post('http://dv_licenses/close'
  );
})

$(document).keyup(function(e){
    if (e.keyCode == 27){
        $('.box').fadeOut();
        $.post('http://dv_licenses/close');
    }
})