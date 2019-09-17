object-edit-parameters
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', handlers='{ parametersHandlers }',
            cols='{ parametersCols }', rows='{ value }', responsive='false')
                #{'yield'}(to='toolbar')
                    #{'yield'}(from='toolbar')
                #{'yield'}(to='body')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='value')
                        span.form-control(if='{ row.type == "calc" }') { row.value }
                        input.form-control(if='{ row.type == "number" }', value='{ row.value }', type='number', min='0.00',
                        onchange='{ handlers.changeNumValue }')
                        i.fa.fa-fw(if='{ row.type == "bool" }', onclick='{ handlers.toggleCheckbox }',
                        class='{ row.value ? "fa-check-square-o" : "fa-square-o" }')
                        input.form-control(if='{ row.type == "string" }', value='{ row.value }', type='text',
                        oninput ='{ handlers.changeValue }')
                        autocomplete(if='{ row.type == "colorlist" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', value-field='value', id-field='id', onchange='{ handlers.changeColorValue }')
                            i.color(style='background-color: \#{ item.color };')
                            | &nbsp;&nbsp;{ item.value }
                        autocomplete(if='{ row.type == "list" }', load-data='{ handlers.getOptions(row.idFeature) }',
                        value='{ row.idValue }', value-field='value', id-field='id', onchange='{ handlers.changeColorValue }')
                            | { item.value }

    script(type='text/babel').
        var self = this

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        self.parametersCols = [
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
        ]

        self.parametersHandlers = {
            getOptions(id) {
                var id = id
                return function () {
                    var _this = this
                    return API.request({
                        object: 'FeatureValue',
                        method: 'Fetch',
                        data: {filters: {field: 'idFeature', value: id}},
                        success(response) {
                            _this.data = response.items
                            if (!_this.isOpen) {
                                _this.data.forEach(item => {
                                    if (item[_this.idField] == _this.opts.value) {
                                        _this.filterValue = item[_this.valueField]
                                    }
                                })
                            }
                            _this.update()
                        }
                    })
                }
            },
            toggleCheckbox(e) {
                this.row.value = !this.row.value
            },
            changeValue(e) {

               // console.log(e)
                var selectionStart = e.target.selectionStart
                var selectionEnd = e.target.selectionEnd

                this.row.value = e.target.value

                this.update()
                e.target.selectionStart = selectionStart
                e.target.selectionEnd = selectionEnd
            },
            changeNumValue(e) {

                console.log(e)
                //var selectionStart = e.target.selectionStart
                //var selectionEnd = e.target.selectionEnd

                this.row.value = e.target.value

                this.update()
                //e.target.selectionStart = selectionStart
                //e.target.selectionEnd = selectionEnd
            },
            changeColorValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
            },
            changeListValue(e) {
                this.row.idValue = this.row.valueIdList = e.target.value
            }
        }

        self.on('update', () => {
            if ('value' in opts)
                self.value = opts.value || []

            if ('name' in opts)
                self.root.name = opts.name
        })

