| import 'pages/settings/parameters/parameters-list-select-modal.tag'

typeobj-edit-parameters
    .row
        .col-md-12
            catalog-static(name='{ opts.name }', add='{ addParameters }', remove='true', handlers='{ parametersHandlers }',
            cols='{ parametersCols }', rows='{ value }', responsive='false')
                #{'yield'}(to='toolbar')
                    #{'yield'}(from='toolbar')
                #{'yield'}(to='body')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='target')
                        i.fa.fa-fw(onclick='{ handlers.toggleTarget }',
                        class='{ row.target ? "fa-check-square-o" : "fa-square-o" }')
                    datatable-cell(name='isMain')
                        i.fa.fa-fw(onclick='{ handlers.toggleMain }',
                        class='{ row.isMain ? "fa-check-square-o" : "fa-square-o" }')
                    datatable-cell(name='isShort')
                        i.fa.fa-fw(onclick='{ handlers.toggleShort }',
                        class='{ row.isShort ? "fa-check-square-o" : "fa-square-o" }')
                    datatable-cell(name='isFilter')
                        i.fa.fa-fw(onclick='{ handlers.toggleFilter }',
                        class='{ row.isFilter ? "fa-check-square-o" : "fa-square-o" }')
                    datatable-cell(name='isMap')
                        i.fa.fa-fw(onclick='{ handlers.toggleMap }',
                        class='{ row.isMap ? "fa-check-square-o" : "fa-square-o" }')





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
            {name: 'target', value: 'Квартира/участок'},
            {name: 'isMain', value: 'В списке'},
            {name: 'isShort', value: 'При наведении'},
            {name: 'isFilter', value: 'В фильтре'},
            {name: 'isMap', value: 'В плане'},
        ]

        self.addParameters = e => {
            modals.create('parameters-list-select-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    self.value = self.value || []

                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.value.map(item => {
                        return item.idFeature
                    })

                    items.forEach(function (item) {
                        if (ids.indexOf(item.id) === -1) {
                            self.value.push({
                                idFeature: item.id,
                                name: item.name,
                                type: item.type
                            })
                        }
                    })

                    let event = document.createEvent('Event')
                    event.initEvent('change', true, true)
                    self.root.dispatchEvent(event)

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.parametersHandlers = {
            toggleTarget(e) {
                this.row.target = !this.row.target
            },
            toggleMain(e) {
                this.row.isMain = !this.row.isMain
            },
            toggleShort(e) {
                this.row.isShort = !this.row.isShort
            },
            toggleFilter(e) {
                this.row.isFilter = !this.row.isFilter
            },
            toggleMap(e) {
                this.row.isMap = !this.row.isMap
            },
        }


        self.on('update', () => {
            if ('value' in opts)
                self.value = opts.value || []

            if ('name' in opts)
                self.root.name = opts.name
        })

