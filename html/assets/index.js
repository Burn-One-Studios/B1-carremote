const resource = GetParentResourceName()

document.onkeydown = function (data) {
	if (data.which == '314' || '27') {
		$('#keyfob').fadeOut(250)
		$.post(`https://${resource}/close`, JSON.stringify({ }))
	}
}

window.addEventListener('message', function(event) {
	if (event.data.type === "open") {
		$('#carConnected').show()

		switch (event.data.battery) {
			case 'battery-0':
				$('#battery-0').show()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-10':
				$('#battery-0').hide()
				$('#battery-10').show()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-20':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').show()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-30':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').show()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-40':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').show()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-50':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').show()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-60':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').show()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-70':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').show()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-80':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').show()
				$('#battery-90').hide()
				$('#battery-100').hide()
				break
			case 'battery-90':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').show()
				$('#battery-100').hide()
				break
			case 'battery-100':
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').show()
				break
			default:
				$('#battery-0').hide()
				$('#battery-10').hide()
				$('#battery-20').hide()
				$('#battery-30').hide()
				$('#battery-40').hide()
				$('#battery-50').hide()
				$('#battery-60').hide()
				$('#battery-70').hide()
				$('#battery-80').hide()
				$('#battery-90').hide()
				$('#battery-100').show()
		}

		let engine = parseInt(event.data.engine)

		if (engine === 1) {
			$('#engineOff').hide()
			$('#engineOn').show()
		} else {
			$('#engineOn').hide()
			$('#engineOff').show()
		}

		let locked = parseInt(event.data.locked)

		if (locked === 1) {
			$('#unlocked').hide()
			$('#locked').show()
		} else {
			$('#locked').hide()
			$('#unlocked').show()
		}

		$('#keyfob').fadeIn(250)
	} else if (event.data.type === "engine") {
		let engine = parseInt(event.data.value)

		if (engine === 1) {
			$('#engineOff').hide()
			$('#engineOn').show()
		} else {
			$('#engineOn').hide()
			$('#engineOff').show()
		}
	} else if (event.data.type === 'locks') {
		let val = parseInt(event.data.value)

		if (val === 1) {
			$('#locked').show()
			$('#unlocked').hide()
		} else {
			$('#unlocked').show()
			$('#locked').hide()
		}
	} else if (event.data.type === 'playSound') {
		let audioPlayer = new Audio('assets/sounds/' + event.data.file + '.ogg')
		audioPlayer.volume = parseFloat(event.data.volume)
		audioPlayer.play()
	}
})

$('body').on('click', '.lock', function(event) {
	$.post(`https://${resource}/lock`, JSON.stringify({}))
})

$('body').on('click', '.unlock', function(event) {
	$.post(`https://${resource}/unlock`, JSON.stringify({}))
})

$('body').on('click', '.engine', function(event) {
	$.post(`https://${resource}/engine`, JSON.stringify({}))
})

$('body').on('click', '.alarm', function(event) {
	$.post(`https://${resource}/alarm`, JSON.stringify({}))
})

$('body').on('click', '.trunk', function(event) {
	$.post(`https://${resource}/trunk`, JSON.stringify({}))
})

$('body').on('click', '.share', function(event) {
	$.post(`https://${resource}/share`, JSON.stringify({}))
})

$('body').on('click', '.findVehicle', function(event) {
	$.post(`https://${resource}/findVehicle`, JSON.stringify({}))
})

$('body').on('click', '.close', function(event) {
	$('#keyfob').fadeOut(250)
	$.post(`https://${resource}/close`, JSON.stringify({}))
})
