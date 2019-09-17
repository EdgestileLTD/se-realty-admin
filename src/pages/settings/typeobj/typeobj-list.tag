| import 'components/catalog.tag'
| import './product-edit-parameters-modal.tag'
| import './typeobj-new-modal.tag'

typeobj-list
    .row
        .col-md-12
            catalog(search='true', sortable='true', object='Type', cols='{ cols }', combine-filters='true'
            add='{ add }', reorder='true',
            remove='{ remove }',
            dblclick='{ productOpen }',
            reload='true', store='typeobj-list')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='code') { row.code }
                    datatable-cell(name='name') { row.name }

    style(scoped).
        :scope {
            display: block;
            position: relative;
        }

        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'Type'
        self.brands = []
        self.categoryFilters = false

        self.add = e => {
            modals.create('typeobj-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {
                        name: this.name.value,
                    }

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Type',
                            method: 'Save',
                            data: params,
                            success(response, xhr) {
                                popups.create({title: 'Успех!', text: 'Тип объекта добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                self.tags.catalog.reload()
                                if (response && response.id)
                                    riot.route(`/settings/typeobj/${response.id}`)
                            }
                        })
                    }
                }
            })
        }

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'code', value: 'Код'},
            { name: 'name', value: 'Наименование'},
        ]
        self.productOpen = e => riot.route(`/settings/typeobj/${e.item.row.id}`)

        observable.on('typeobj-reload', () => {
            self.tags.catalog.reload()
        })
        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {})
            self.tags.catalog.tags.datatable.on('reorder-end', () => {
                let {current, limit} = self.tags.catalog.pages
                let params = { indexes: [] }
                let offset = current > 0 ? (current - 1) * limit : 0

                self.tags.catalog.items.forEach((item, sort) => {
                    item.sort = sort + offset
                    params.indexes.push({id: item.id, sort: sort + offset})
                })

                API.request({
                    object: 'Type',
                    method: 'Sort',
                    data: params,
                    notFoundRedirect: false
                })

                self.update()
            })
        })
