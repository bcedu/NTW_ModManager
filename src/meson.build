
srcs = files([
    'configs/Constants.vala',
    'configs/Settings.vala',
    'widgets/HeaderBar.vala',
    'views/AppView.vala',
    'views/View1.vala',
    'views/View2.vala',
    'views/ViewConf.vala',
    'controllers/ViewController.vala',
    'controllers/AppController.vala',
    'Application.vala',
    'Window.vala',
    'ModManager.vala',
    'Main.vala'
])


# Dependences
deps = [
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gtk+-3.0'),
    dependency('granite'),
    dependency('gee-0.8'),
    meson.get_compiler('vala').find_library('posix'),
    dependency('unity')
]


executable(
    meson.project_name(),
    srcs,
    asresources,
    dependencies: deps,
    install: true
)
