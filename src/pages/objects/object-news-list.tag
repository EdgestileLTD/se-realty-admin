| import 'components/catalog.tag'

object-news-list

    catalog(object='ObjectNews', search='true', sortable='true', cols='{ cols }', reload='true',
        add='{ permission(add, "news", "0100") }',
        remove='{ permission(remove, "news", "0001") }',
        dblclick='{ permission(newsOpen, "news", "1000") }', store='object-news-list',
        combine-filters='true', filters='{ objectFilters }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='imageUrlPreview')
                img(src='{ row.imageUrlPreview }', alt='', width='32', height='32')
            datatable-cell(name='date') { row.date }
            datatable-cell(name='name') { row.name }

    style.
        datatable-head-cell[name=id] {
            width: 50px;
        }
        datatable-head-cell[name=imageFile] {
            width: 50px;
        }
        datatable-head-cell[name=date] {
            width: 100px;
        }



    script(type='text/babel').
        var self = this
        self.id = 0
        self.objectFilters = [{field: 'idObject', sign: 'IN', value: self.id }]

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'ObjectNews'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'imageFile', value: 'Фото'},
            {name: 'date', value: 'Дата публ.'},
            {name: 'name', value: 'Заголовок'}
        ]

        self.add = () => {
            modals.create('object-new-modal', {
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    var data = {
                        name: this.name.value,
                        idObject: self.id
                    }
                    console.log(data)
                    API.request({
                        object: 'ObjectNews',
                        method: 'Save',
                        data: data,
                        success(response, xhr) {
                            self.tags.catalog.reload()
                            self.update()
                            if (response && response.id)
                            riot.route(`/objects/events/${response.id}`)
                        }
                    })
                    this.modalHide()
                }
            })
        }

        self.newsOpen = e => {
            riot.route(`/objects/events/${e.item.row.id}`)
        }

        observable.on('object-new-reload', (id) => {
            self.id = id
            self.objectFilters = [{field: 'idObject', sign: 'IN', value: self.id }]
            console.log(self.objectFilters)
            self.update()
            self.tags.catalog.reload()
        })

        self.on('update', () => {
            if ('name' in opts)
                self.root.name = opts.name
            if (self.id) {
                self.objectFilters = [{field: 'idObject', sign: 'IN', value: self.id }]
                //alert(self.id)
                self.update()
                self.tags.catalog.reload()
            }
        })


