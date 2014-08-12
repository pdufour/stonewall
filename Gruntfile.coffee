module.exports = (grunt) ->
	# Package
	# =======
	pkg = require './package.json'

	modules = [
		'src/index.coffee'
		'src/util.coffee'
		'src/messages.coffee'
		'src/rules.coffee'
		'src/ruleset.coffee'
		'src/base.coffee'
		'src/plugins/rivets.coffee'
		'src/setup.coffee'
	]

	# Configuration
	# =============
	grunt.initConfig
		pkg: pkg
		coffee:
			compile:
				options:
					join: true
					expand: true
					bare: false
				files:
					'<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js': modules
		uglify:
			coffee:
				options:
					mangle: false
					compress: false
					beautify: true
					preserveComments: 'some'
					banner: '''
					/*!
					 * Stonewall
					 * @author Paul Dufour
					 * @company Brit + Co
					 */
					 '''
		umd:
			coffee:
				src: '<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js'
				dest: '<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js'
				deps:
					default: ['_','Backbone','rivets']
					amd: ['underscore', 'backbone', 'rivets'],
					cjs: ['underscore', 'backbone', 'rivets'],
					global: ['_', 'Backbone', 'rivets'],
		watch:
			coffee:
				files: ['src/*.coffee', 'src/**/*.coffee']
				tasks: ['coffee:compile']

	# Dependencies
	# ============
	for name of pkg.devDependencies when name.substring(0, 6) is 'grunt-'
		grunt.loadNpmTasks name

	# Tasks
	# =====
	grunt.registerTask 'build', ->
		# Build for release
		files = grunt.config('coffee.compile.files')

		for filename, filevalues of files
			break

		grunt.config.set 'uglify.coffee.files', {
			'<%= pkg.distDirectory %>/<%= pkg.name %>-<%= pkg.version %>.js': '<%= pkg.distDirectory %>/<%= pkg.name %>-latest.js'
		}

		grunt.registerTask 'after:build', ->
			# Rebuild 'latest' version now
			grunt.config.set 'uglify.coffee.files', files
			grunt.task.run 'coffee:compile'

		grunt.task.run 'coffee:compile', 'umd:coffee', 'uglify:coffee', 'after:build'
