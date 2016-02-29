var embrelloColors = function() {
	var self = this;
	self.colors = [
		{
			name: 'blue',
			hex: '#2693ff'
		},
		{
			name: 'turquoise',
			hex: '#00a4b0'
		},
		{
			name: 'green',
			hex: '#83Ba1f'
		},
		{
			name: 'clean-green',
			hex: '#00b05b'
		},
		{
			name: 'orange',
			hex: '#e56c19'
		},
		{
			name: 'deep-red',
			hex: '#c81c1c'
		}
	];
	self.defaultColor = 'clean-green';
	
	self.getColorHex = function(colorName) {
		// alert('asöld');
		// alert(JSON.stringify(self.colors));
		return $.grep(self.colors, function(obj) {
			return obj.name === colorName;
		})[0].hex;
	};
};
