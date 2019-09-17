| import md5 from 'blueimp-md5/js/md5.min.js'
| import 'pages/auth.tag'
| import 'pages/applications/applications.tag'
| import 'pages/objects/objects.tag'
//| import 'pages/persons/persons.tag'
| import 'pages/questions/questions.tag'
| import 'pages/news/news.tag'
| import 'pages/reviews/reviews.tag'
| import 'pages/images/images-manager.tag'
| import 'pages/images/images.tag'
| import 'pages/prices/prices-files.tag'
| import 'pages/files/files.tag'
| import 'pages/settings/settings.tag'
| import 'pages/sections/sections.tag'
| import 'pages/analytics/analytics.tag'
| import 'pages/import/import.tag'
| import 'pages/mailing/mailing.tag'
| import 'pages/not-found.tag'
| import 'modals/account-add-modal.tag'
| import 'modals/account-settings-modal.tag'
| import parallel from 'async/parallel'
| import 'components/datetime-picker.tag'





include src/blocks/old-browser

app
    div(if="{ unsupported }")
        +oldBrowser

    loader(if='{ loader }', size='large', text='Загрузка')
    auth(if='{ !app.auth && !loader }')
    images-manager(if='{ imageLoad && !loader }')

    .app-layout(if='{ sidebarShow }', onclick='{ toggleSidebar }')

    .wrapper(if='{ !unsupported && app.auth && !loader && !imageLoad}')
        .sidebar-left(class='{ active: sidebarShow }')
            .logo
            .menu
                ul
                    li(each='{ sidebar }', if='{ checkPermission(permission, 1000) }', class='{ active: name == tab }')
                        a(href='#\{ link \}')
                            i(class='fa { icon }')
                            span { title }
                    li.hidden-md.hidden-sm.hidden-lg
                        a(href='{ app.config.projectURL }', target='_blank', title='Перейти на сайт')
                            i.fa.fa-share
                            span Перейти на сайт
                    li.hidden-md.hidden-sm.hidden-lg
                        a(onclick='{ logout }', href='#')
                            i.fa.fa-sign-out
                            span Выход

        .main-container.clearfix
            .navbar.navbar-default.navbar-fixed-top.m-b-2
                .container-fluid
                    .navbar-header
                        button(onclick='{ toggleSidebar }', type='button', class='navbar-toggle pull-left m-x-2')
                            span.sr-only
                            span.icon-bar
                            span.icon-bar
                            span.icon-bar
                        a.navbar-brand { headTitle || 'Shop 24' }

                    .navbar-collapse.collapse
                        ul.nav.navbar-nav.navbar-right
                            li(if='{ app.config.projectURL }')
                                a(href='{ app.config.projectURL }', target='_blank', title='Перейти на сайт')
                                    i.fa.fa-share
                            li
                                a(onclick='{ logout }', href='#')
                                    i.fa.fa-fw.fa-sign-out
                                    | Выход
            .main.col-md-12(style='width: 100%;')
                desktop(if='{ tab == "desktop" }')
                    h4 Рабочий стол - в разработке
                applications(if='{ tab == "applications" }')
                objects(if='{ tab == "objects" }')
                payments(if='{ tab == "payments" }')
                persons(if='{ tab == "persons" }')
                news(if='{ tab == "news" }')
                reviews(if='{ tab == "reviews" }')
                questions(if='{ tab == "questions" }')
                sections(if='{ tab == "sections" }')
                prices-files(if='{ tab == "prices" }')
                images(if='{ tab == "images" }')
                //files(if='{ tab == "files" }')
                analytics(if='{ tab == "analytics" }')
                settings(if='{ tab == "settings" }')
                import(if='{ tab == "import" }')
                mailing(if='{ tab == "mailing" }')
                not-found(if='{ tab == "not-found" }')


    style(scoped).
        .app-layout {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #000;
            opacity: 0.7;
            z-index: 1100;
        }

    script(type='text/babel').
        var self = this

        self.app = app
        self.mixin('permissions')
        self.auth = false
        self.sidebarShow = false
        self.loader = true
        self.auth = app.auth
        self.imageLoad = false

        var route = riot.route.create()

        route(tab => {
            if (tab == '') {
                let links = self.sidebar.filter(i => self.checkPermission(i.permission, "1000"))
                if (links.length) {
                    riot.route(links[0].link)
                } else {
                    riot.route('')
                    observable.trigger('not-found')
                }
            } else {
                if (tab == 'imageLoad') {
                    self.imageLoad = true
                    self.update()
                    return;
                }
                let idx = self.sidebar.map(item => item.name).indexOf(tab)
                if (idx !== -1 && self.checkPermission(self.sidebar[idx].permission, 1000)) {
                    var item = self.sidebar.filter(item => item.name === tab)
                    self.headTitle = item[0].title
                    self.tab = tab
                } else {
                    if (tab == "import") {
                        self.headTitle = "Импорт"
                        self.tab = tab
                        observable.trigger('import-start')
                    } else observable.trigger('not-found')
                }
            }
            self.sidebarShow = false
            document.body.classList.remove('modal-open')
            window.scrollTo(0, 0)
            self.update()
        })

        self.unsupported = app.checkUnsupported()

        self.sidebar = [
            {title: 'Заявки', name: 'applications', link: 'applications', permission: 'applications', icon: 'fa-info-circle'},
            {title: 'Объекты', name: 'objects', link: 'objects', permission: 'objects', icon: 'fa-building'},
        //{title: 'Клиенты', name: 'persons', link: 'persons', permission: 'contacts', icon: 'fa-users'},
        //    {title: 'Рассылки', name: 'mailing', link: 'mailing', permission: 'contacts', icon: 'fa-paper-plane'},
            {title: 'Новости', name: 'news', link: 'news', permission: 'news', icon: 'fa-newspaper-o'},
            {title: 'Отзывы', name: 'reviews', link: 'reviews', permission: 'reviews', icon: 'fa-comment-o'},
            {title: 'Вопросы', name: 'questions', link: 'questions', permission: 'questions', icon: 'fa-comments-o'},
            {title: 'Разделы', name: 'sections', link: 'sections', permission: 'sections', icon: 'fa-file-text'},
            {title: 'Документы', name: 'prices', link: 'prices', permission: 'prices', icon: 'fa-cloud-download'},
            {title: 'Картинки', name: 'images', link: 'images', permission: 'images', icon: 'fa-picture-o'},
            //{title: 'Файлы', name: 'files', link: 'files', permission: 'files', icon: 'fa-cloud-download'},
            //{title: 'Аналитика', name: 'analytics', link: 'analytics', permission: '', icon: 'fa-area-chart '},
            {title: 'Настройки', name: 'settings', link: 'settings', permission: '', icon: 'fa-cogs'},
        ]

        self.toggleSidebar = () => {
            self.sidebarShow = !self.sidebarShow
            if (self.sidebarShow)
                document.body.classList.add('modal-open')
            else
                document.body.classList.remove('modal-open')
        }


        self.logout = () => {
            localStorage.removeItem('shop24')
            localStorage.removeItem('shop24_permissions')
            localStorage.removeItem('shop24_cookie')
            localStorage.removeItem('shop24_user')
            localStorage.removeItem('shop24_main_user')
            window.location.reload()
        }

        self.accountAdd = () => {
            modals.create('account-add-modal', {
                type: 'modal-primary',
                size: 'modal-sm'
            })
        }

        self.accountChange = e => {
            var account = e.item.account

            if (account.isMain) {
                let mainUser = JSON.parse(localStorage.getItem('shop24_main_user'))
                var { login, hash, project } = mainUser
            } else {
                var { login, hash, project } = account
            }

            app.login({
                project: project,
                serial: login,
                password: hash,
                success(response, secookie) {
                    if (response.permissions)
                        localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                    localStorage.setItem('shop24_cookie', secookie)
                    localStorage.setItem('shop24', JSON.stringify(response.config))
                    window.location.reload()
                },
                error(response) {
                    self.update()
                }
            })
        }

        self.accountSettings = () => {
            modals.create('account-settings-modal', {
                type: 'modal-primary'
            })
        }


        observable.on('auth', auth => {
            self.loader = false
            self.update()
        })



        observable.on('not-found', () => {
            self.headTitle = '404'
            self.tab = 'not-found'
            self.update()
        })

        self.parseGetParams = () => {
            var $_GET = {};
            var __GET = window.location.search.substring(1).split("&");
            for(var i = 0; i < __GET.length; i++) {
                var getVar = __GET[i].split("=");
                $_GET[getVar[0]] = typeof(getVar[1])=="undefined" ? "" : getVar[1];
            }
            return $_GET;
        }

        self.on('mount', () => {
            let params = self.parseGetParams()
            if (params.login && params.password) {
                localStorage.removeItem('shop24_cookie')
                app.login({
                    serial: params.login.trim(),
                    password: md5(params.password.trim()),
                    success(response, secookie) {
                        if (response.permissions)
                            localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                        localStorage.setItem('shop24_cookie', secookie)
                        localStorage.setItem('shop24', JSON.stringify(response))
                        app.init()
                        riot.route.start(true)
                        location.search = ''
                        /*
                        var mainUser = {
                            project: initApi.project,
                            login: params.login.trim(),
                            hash: md5(params.password.trim()),
                        }
                        alert();

                        localStorage.setItem('shop24_main_user', JSON.stringify(mainUser))
                        localStorage.setItem('shop24_cookie', secookie)
                        localStorage.setItem('shop24', JSON.stringify(response.config))
                        if (response.permissions)
                        localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))
                        location.search = ''
                        */
                    }
                })
                return
            }


            API.authCheck({
                success(response) {
                    if (response.permissions)
                        localStorage.setItem('shop24_permissions', JSON.stringify(response.permissions))

                    app.init()
                    riot.route.start(true)
                },
                error() {
                    let user = localStorage.getItem('shop24_user')

                    if (user) {
                        app.restoreSession(user)
                    } else {
                        app.init()
                        riot.route.start(true)
                    }
                }
            })
        })