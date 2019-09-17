| import 'components/catalog.tag'
| import 'components/catalog-static.tag'
| import 'components/catalog-tree.tag'
| import 'components/datatable.tag'
| import 'pages/objects/object-new-modal.tag'


location-list
    .row
        .col-md-12
            catalog(object='Location', cols='{ cols }', combine-filters='true'
            disable-limit='true', disable-col-select='true', reorder='true',
            add='{ add }',
            remove='{ remove }',
            dblclick='{ objectOpen }',
            reload='true', store='object-list', filters='{ categoryFilters }')
                #{'yield'}(to='body')
                    datatable-cell(name='') { row.id }
                    datatable-cell(name='')
                        img(src='{ row.imageUrlPreview }', alt='', width='60')
                    datatable-cell(name='')
                        i(class='fa { row.isActive ? "fa-eye" : "fa-eye-slash text-muted" } ')
                    datatable-cell(name='') { row.name }
                    datatable-cell(name='') { row.address }




    script(type='text/babel').
        var self = this

        self.collection = 'Location'

        self.mixin('remove')

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'isActive', value: 'Вид'},
            { name: 'name', value: 'Наименование'},
            { name: 'address', value: 'Адрес'},
        ]

        self.selectedCategory = 4
        self.categoryFilters = true

        self.rows = []

        observable.on('location-reload', () => {
            self.tags.catalog.reload()
        })


        self.add = () => {
            modals.create('object-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {
                        name: this.name.value
                    }

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Location',
                            method: 'Save',
                            data: params,
                            success(response, xhr) {
                                popups.create({title: 'Успех!', text: 'Объект добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                self.tags.catalog.reload()
                                if (response && response.id)
                                riot.route(`/objects/location/${response.id}`)
                            }
                        })
                    }
                }
            })
        }

        self.objectOpen = e => riot.route(`/objects/location/${e.item.row.id}`)

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                //self.getLabels()
            })
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'Location',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })

