section-list
    .row
        .col-md-4.col-xs-12
            catalog(name='section-page', object='SectionPage', cols='{ pageCols }' reload='true', onclick='{ pageclick}',
                disable-limit='true', disable-col-select='true'
            )
                #{'yield'}(to='body')
                    datatable-cell(name='isActive')
                        i(class='fa { row.isActive ? "fa-eye" : "fa-eye-slash text-muted" } ')
                    datatable-cell(name='code') { row.code }
                    datatable-cell(name='title') { row.title }
                    datatable-cell(name='page') { row.page }
                    datatable-cell(name='section') { row.section }

        .col-md-8.col-xs-12
            catalog(name='section-item', sortable='true', object='SectionItem', cols='{ cols }', combine-filters='true'
            disable-limit='true', disable-col-select='true',
            add='{ add }', remove='{ remove }',
            dblclick='{ objectOpen }', filters='{ categoryFilters }')
                #{'yield'}(to='body')
                    datatable-cell(name='id') { row.id }
                    datatable-cell(name='isActive')
                        i(class='fa { row.isActive ? "fa-eye" : "fa-eye-slash text-muted" } ')
                    datatable-cell(name='imageUrlPreview')
                        img(src='{ row.imageUrlPreview }', alt='', width='60')
                    datatable-cell(name='name') { row.name }
                    datatable-cell(name='description') { row.description }
                    datatable-cell(name='sort', style='width: 10px;') { row.sort }


    script(type='text/babel').
        var self = this

        self.collection = 'SectionItem'
        self.idSection = 0;
        self.categoryFilters = [{field: 'idSection', sign: 'IN', value: self.idSection }]

        self.mixin('remove')

        var route = riot.route.create()


        self.pageCols = [
            { name: 'isActive', value: 'Вид'},
            { name: 'code', value: 'Код'},
            { name: 'title', value: 'Наименование'},
            { name: 'page', value: 'Страница'},
            { name: 'section', value: 'Раздел'},
        ]

        self.cols = [
            { name: 'id', value: '#'},
            { name: 'isActive', value: 'Вид'},
            { name: 'imageUrlPreview', value: ''},
            { name: 'name', value: 'Наименование'},
            { name: 'description', value: 'Примечание'},
            { name: 'sort', value: 'Поряок'},
        ]

        self.one('updated', () => {

        })

        observable.on('section-reload', () => {
            self.tags['section-item'].reload()
        })

        self.pageclick = e => {
            let rows = self.tags['section-page'].tags.datatable.getSelectedRows()
            self.idSection = rows[0].idSection;
            self.categoryFilters = [{field: 'idSection', sign: 'IN', value: self.idSection }]
            self.update()
            self.tags['section-item'].reload()
        }

        self.add = e => {
            if (self.idSection)
                riot.route(`/sections/new?section=${self.idSection}`)
            else
                popups.create({title: 'Внимание!', text: 'Для добавления записи необходимо выбрать раздел!', style: 'popup-warning'})

        }

        self.objectOpen = e => riot.route(`/sections/${e.item.row.id}`)


        self.on('mount', () => {
            riot.route.exec()
        })