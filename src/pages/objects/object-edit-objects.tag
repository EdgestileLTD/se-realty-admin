| import 'pages/objects/import-items-modal.tag'

object-edit-objects
    //loader(if='{ loader }')
    .row
        .col-md-12
            catalog(sortable='true', object='ObjectItems', cols='{ cols }', combine-filters='true'
            add='{ addItem }',
            remove='{ remove }',
            dblclick='{ objectOpen }', reorder='true',
            reload='true', store='object-list', filters='{ objectFilters }')
                #{'yield'}(to='head')
                    #{'yield'}(to='head')
                        button.btn.btn-primary(type='button', onclick='{ parent.importObjects }', title='Импорт')
                            i.fa.fa-download


                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='imageUrlPreview', style='width: 80px;')
                        img(src='{ row.imageUrlPreview }', alt='', width='64')
                    datatable-cell(name='isActive')
                        i(class='fa { row.isActive ? "fa-eye" : "fa-eye-slash text-muted" } ')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(each='{ item, i in row.params }', name='f{ i }')
                        b { row.params[i].value }
                        |  { row.params[i].measure }


    script(type='text/babel').
        var self = this

        self.collection = 'ObjectItems'
        self.mixin('remove')

        Object.defineProperty(self.root, 'value', {
            get() {
                return self.value || []
            },
            set(value) {
                self.value = value || []
                self.update()
            }
        })

        // self.loader = false
        self.id = 0
        self.cols = []
        self.rows = []
        self.objectFilters = []

        self.addItem = e => {
            modals.create('object-new-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    var name = this.name.value
                    API.request({
                        object: 'ObjectItems',
                        method: 'Save',
                        data: { idObject: self.id, name: name },
                        success(response, xhr) {
                            self.tags.catalog.reload()
                            self.update()
                            if (response && response.id)
                                riot.route(`/objects/items/${response.id}`)
                        }
                    })
                    this.modalHide()
                }
            })
        }


        self.objectOpen = e=> {
            riot.route(`/objects/items/${e.item.row.id}`)
        }

        observable.on('items-reload', () => {
            self.tags.catalog.reload()
        })

        self.importObjects = (e) => {
            modals.create('import-items-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                        console.log(this)

                    API.request({
                        object: 'ObjectItems',
                        method: 'Import',
                        data: { id: self.id, content: _this.item.importtext },
                        success(response, xhr) {
                            self.update()
                            self.tags.catalog.reload()
                        }
                    })
                    popups.create({title: 'Успех!', text: 'Импорт завершен!', style: 'popup-success'})
                    _this.modalHide()
                }
            })
        }


        self.on('update', () => {
            if ('value' in opts)
                self.value = opts.value || []

            if ('name' in opts)
                self.root.name = opts.name

            if (opts.id && self.id != opts.id) {
                self.id = opts.id
                self.setCols(self.id)
            }
        })

        self.one('updated', () => {
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'ObjectItems',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })

        self.setCols =(id)=> {
            //self.loader = true
            self.cols = [
                { name: 'id', value: '#'},
                { name: 'imageUrlPreview', value: ''},
                { name: 'isActive', value: 'Вид'},
                { name: 'name', value: 'Наименование'},
            ]
            API.request({
                object: 'ObjectItems',
                method: 'Items',
                data: { id: id },
                success(response, xhr) {
                    for(var i=0; i<response.items.length; i++){
                        self.cols.push(response.items[i])
                    }
                    let value = id
                    self.objectFilters = [{field: 'idObject', sign: 'IN', value }]
                    self.update()
                    self.tags.catalog.reload()
                    // self.loader = false
                }
            })
        }





