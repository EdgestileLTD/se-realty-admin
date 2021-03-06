| import 'pages/objects/files/files-categories-edit-modal.tag'

prices-categories-list
    catalog(object='PricesCategory', cols='{ cols }', remove='{ remove }', dblclick='{ addEdit }', add='{ addEdit }',
    reload='true', store='files-categories-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='code') { row.code }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('remove')
        self.collection = 'PricesCategory'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'code', value: 'Код'},
            {name: 'name', value: 'Наименование'},
        ]

        self.addEdit = (e) => {
            let id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('files-categories-edit-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    let _this = this
                    _this.item.idObject = opts.idObject
                    let params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'PricesCategory',
                            method: 'Save',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Категория сохранена!', style: 'popup-success'})
                                observable.trigger('files-categories-reload')
                                _this.modalHide()
                            }
                        })
                    }
                }
            })
        }

        observable.on('files-categories-reload', () => {
            self.tags.catalog.reload()
        })