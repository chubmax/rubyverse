require 'rubygems'
require 'bundler/setup'

require 'opengl'
require 'glu'
require 'glut'

require_relative 'opengl_sugar/open_gl_sugar'
require_relative 'control/universe'
require_relative 'model/body'

class Rubyverse
  # Mixin GL and GLUT namespaces available to make code easier to read
  include Gl
  include Glu
  include Glut
  include OpenGlSugar

  NEAR_PLANE = 0.1
  FAR_PLANE = 200.0

  def run(*args)
    @width = 800.0
    @height = 600.0

    @view_angle = 0

    Glut.glutInit
    Glut.glutInitWindowPosition(0, 0)
    Glut.glutInitWindowSize(@width, @height)
    Glut.glutInitDisplayMode(GLUT_DEPTH | GLUT_RGB | GLUT_DOUBLE)

    @zoom_factor = 1.0
    @window = Glut.glutCreateWindow('Rubyverse')

    glutDisplayFunc(method(:render).to_proc)
    glutIdleFunc(method(:idle).to_proc)

    glClearColor(0.0, 0.0, 0.1, 0)
    glShadeModel(GL_SMOOTH)

    glMatrixMode(GL_PROJECTION)
    glLoadIdentity
    gluPerspective(50.0 * @zoom_factor, @width / @height, NEAR_PLANE, FAR_PLANE)
    glMatrixMode(GL_MODELVIEW)

    glEnable(GL_CULL_FACE)
    glEnable(GL_DEPTH_TEST)
    glEnable(GL_LIGHTING)
    glEnable(GL_LIGHT0)
    glLightfv(GL_LIGHT0, GL_DIFFUSE, [0.9, 0.9, 1, 1])
    glLightfv(GL_LIGHT0, GL_SPECULAR, [0.9, 1, 1, 1])
    glLightfv(GL_LIGHT0, GL_POSITION, [-1, 0, 0, 0])

    create_universe

    Glut.glutMainLoop
  end

  def create_universe
    @universe = Universe.new(Body.new('Vulcan', 300.0, [-2.0, 0.0, 0.0], [0.0, 0.0, 0.06]),
                             Body.new('Juno', 280.0, [2.0, 0.0, 0.0], [0.0, 0.0, -0.06]),
                             Body.new('Sukey', 100.0, [0.0, 10.0, 0.0], [0.07, 0.0, 0.0])
    )
  end

  def render
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    glMatrixMode(GL_MODELVIEW)
    glLoadIdentity

    # Camera
    glTranslatef(0, 0, -50)
    # gluLookAt(0, 30, 0, 0, 0, 0, 0, 0, 1)
    # rotation_degrees_per_frame = 0.0
    # @view_angle = (rotation_degrees_per_frame + @view_angle) % 360
    # glRotate(@view_angle, 0, 1, 0)

    # Lights
    transform do
      # If ths light is directional, I don't think the position matters.
  #    glTranslatef(100, 0, 0)
      glLightfv(GL_LIGHT0, GL_POSITION, [-0.5, 0, 0.8, 0])
    end

    # Objects
    # transform do
    #   glTranslatef(-1, 0, -5)
    #   glMaterialfv(GL_FRONT, GL_DIFFUSE, [0.8, 0.9, 0.8, 1])
    #   Glut.glutSolidSphere(2, 40, 40)
    # end

    @universe.render

    Glut.glutSwapBuffers
  end

  def idle
    @universe.run_simulation_tick
    glutPostRedisplay
  end
end