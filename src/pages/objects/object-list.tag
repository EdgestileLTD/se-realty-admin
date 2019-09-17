| import 'components/catalog.tag'
| import 'components/catalog-static.tag'
| import 'components/catalog-tree.tag'
| import 'components/datatable.tag'
| import 'pages/objects/object-new-modal.tag'


object-list
    .row
        .col-md-3.hidden-xs.hidden-sm
            catalog-tree(object='Type', label-field='{ "name" }', children-field='{ "childs" }',
            reload='true', descendants='true')
        .col-xs-12.hidden-lg.hidden-md.m-b-2
            select.form-control(onchange='{ select }')
                option(each='{ row in rows }', value='{ row.id }') { row.name }
        .col-md-9.col-xs-12
            catalog(object='Objects', cols='{ cols }', combine-filters='true'
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
                    datatable-cell(name='', style="width: 20%") { row.name }
                    datatable-cell(name='', style="width: 20%") { row.typeName }
                    datatable-cell(name='') { row.addrName }
                    datatable-cell(name='', style='width: 5%;') { row.objectCount }



    script(type='text/babel').
        var self = this

        self.collection = 'Objects'

        self.mixin('remove')

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'isActive', value: 'Вид'},
            { name: 'name', value: 'Наименование'},
            { name: 'typeName', value: 'Тип'},
            { name: 'address', value: 'Адрес'},
            { name: 'count', value: 'В продаже'},
        ]

        self.selectedCategory = 4
        self.categoryFilters = true

        self.rows = []

        observable.on('products-reload', () => {
            self.tags.catalog.reload()
        })

        observable.on('categories-reload', () => {
            self.tags['catalog-tree'].reload()
        })

        self.select = e => {
            var id = e.target.value
            self.selectedCategory = id
            self.categoryFilters = [{field: 'idType', sign: 'IN', id}]
            self.update()
            self.tags.catalog.reload()
        }

        self.add = () => {
            modals.create('object-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {
                        name: this.name.value,
                        idType: self.selectedCategory,
                    }

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Objects',
                            method: 'Save',
                            data: params,
                            success(response, xhr) {
                                popups.create({title: 'Успех!', text: 'Объект добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                self.tags.catalog.reload()
                                if (response && response.id)
                                riot.route(`/objects/${response.id}`)
                            }
                        })
                    }
                }
            })
        }

        self.objectOpen = e => riot.route(`/objects/${e.item.row.id}`)

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                //self.getLabels()
            })
            self.tags['catalog-tree'].tags.treeview.on('nodeselect', node => {
                self.selectedCategory = node.__selected__ ? node.id : undefined
                let items = self.tags['catalog-tree'].tags.treeview.getSelectedNodes()
                if (items.length > 0) {
                    let value = items.map(i => i.id).join(',')
                    self.categoryFilters = [{field: 'idType', sign: 'IN', value}]
                } else {
                    self.categoryFilters = false
                }
                self.update()
                self.tags.catalog.reload()
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
                    object: 'Objects',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })
                self.update()
            })
        })




        self.on('mount', () => {
            API.request({
                object: 'Type',
                method: 'Fetch',
                success(response) {
                    self.rows = response.items
                    self.update()
                }
            })
        })
