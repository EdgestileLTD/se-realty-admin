| import 'components/catalog.tag'

pets-list

    catalog(search='true', sortable='true', object='Pet', cols='{ cols }', reload='true', store='pats-list',
        add='{ permission(add, "products", "0100") }',
        remove='{ permission(remove, "products", "0001") }',
        dblclick='{ permission(edit, "products", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Pet'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование' },
        ]

        self.add = () => riot.route('/products/pets/new')

        self.edit = e => riot.route(`products/pets/${e.item.row.id}`)

        observable.on('pets-reload', () => {
            self.tags.catalog.reload()
        })