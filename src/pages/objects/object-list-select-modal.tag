object-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Объекты
		#{'yield'}(to="body")
			catalog(object='Objects', cols='{ parent.cols }', search='true', reload='true', sortable='true')
				#{'yield'}(to='body')
					datatable-cell(name='id') { row.id }
					datatable-cell(name='imageUrlPreview')
						img(src='{ row.imageUrlPreview }', alt='', width='60')
					datatable-cell(name='typeName') { row.typeName }
					datatable-cell(name='name') { row.name }
					datatable-cell(name='address') { row.address }
		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	script(type='text/babel').
		var self = this

		self.cols = [
			{ name: 'id', value: '#'},
			{ name: 'imageUrlPreview', value: ''},
			{ name: 'typeName', value: 'Тип'},
			{ name: 'name', value: 'Наименование'},
			{ name: 'address', value: 'Адрес'},
		]

