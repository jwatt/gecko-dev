# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

from marionette.marionette_test import MarionetteTestCase, skip_if_b2g

@skip_if_b2g
class TestTitleChrome(MarionetteTestCase):
    def setUp(self):
        MarionetteTestCase.setUp(self)
        self.marionette.set_context("chrome")
        self.win = self.marionette.current_window_handle
        self.marionette.execute_script("window.open('chrome://marionette/content/test.xul', 'foo', 'chrome,centerscreen');")
        self.marionette.switch_to_window('foo')
        self.assertNotEqual(self.win, self.marionette.current_window_handle)

    def tearDown(self):
        self.assertNotEqual(self.win, self.marionette.current_window_handle)
        self.marionette.execute_script("window.close();")
        self.marionette.switch_to_window(self.win)
        MarionetteTestCase.tearDown(self)

    def test_get_chrome_title(self):
        title = self.marionette.execute_script("return window.document.documentElement.getAttribute('title');")
        self.assertEqual(title, self.marionette.title)
        self.assertEqual('Title Test', self.marionette.title)

class TestTitle(MarionetteTestCase):
    def test_get_html_title(self):
        test_html = self.marionette.absolute_url("test.html")
        self.marionette.navigate(test_html)
        self.assertEqual('Marionette Test', self.marionette.title)
