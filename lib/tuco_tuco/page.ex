defmodule TucoTuco.Page do
  import TucoTuco.Retry
  import TucoTuco.Finder

  @moduledoc """
    This module contains all the functions associated with querying the
    state of the current page.

    You use them in tests like this:

    ```
      assert Page.has_css? "table#fruit tr.first"
    ```

    # About Retries
    It is important to use the ```has_no_x``` type functions if there
    is Javascript running that could modify the page. You will not get
    correct results if you do something like ```assert !has_css? "h2.foo"```,
    instead you should use ```assert has_no_css "h2.foo"```.

  """

  @doc """
    Does the page have an element matching the specified css selector?

    Options include:

      * :count - Specify exactly the number of occurrences on the page of the selector
      that must be found for this to be true.

  """
  def has_css? css, options \\ [] do
    has_selector? :css, css, options
  end

  def has_no_css? css do
    has_no_selector? :css, css
  end

  @doc """
    Does the page have an element matching the xpath selector?

    Options include:

      * :count - Specify exactly the number of occurrences on the page of the selector
      that must be found for this to be true.

  """
  def has_xpath? xpath, options \\ [] do
    has_selector? :xpath, xpath, options
  end

  def has_no_xpath? xpath do
    has_no_selector? :xpath, xpath
  end

  @doc """
    Does the page have a text field or text area with the id, name or label?
  """
  def has_field? text do
    retry fn -> is_element? find(:fillable_field, text) end
  end

  @doc """
    Does the page not have a link containing the specified text, id or name.
  """
  def has_no_field? text do
    retry fn -> is_not_element? find(:fillable_field, text) end
  end

  @doc """
    Does the page have a link containing the specified text, id or name.
  """
  def has_link? text do
    retry fn -> is_element? find(:link, text) end
  end

  @doc """
    Does the page not have a link containing the specified text, id or name.
  """
  def has_no_link? text do
    retry fn -> is_not_element? find(:link, text) end
  end

  @doc """
    Does the page have a button.

    Finds by text, id or name.
  """
  def has_button? text do
    retry fn-> is_element? find(:button, text) end
  end

  @doc """
    Does the page not have a button.

    Finds by text, id or name.
  """
  def has_no_button? text do
    retry fn -> is_not_element? find(:button, text) end
  end

  @doc """
    Does the page have a checkbox or radio button that is checked?

    Finds by label or id.
  """
  def has_checked_field? text do
    retry fn ->
      element = find(:checkbox_or_radio, text)
      case is_element?(element) do
        true -> WebDriver.Element.selected? element
        false -> false
      end
    end
  end

  @doc """
    Does the page not have a checkbox or radio button that is checked?

    Finds by label or id.
  """
  def has_no_checked_field? text do
    retry fn ->
      element = find(:checkbox_or_radio, text)
      case is_element?(element) do
        true -> !WebDriver.Element.selected?(element)
        false -> true
      end
    end
  end

  @doc """
    Does the page have a checkbox or radio button that is unchecked?

    Finds by label or id.
  """
  def has_unchecked_field? text do
    retry fn ->
      element = find(:checkbox_or_radio, text)
      case is_element?(element) do
        true -> !WebDriver.Element.selected? element
        false -> false
      end
    end
  end

  @doc """
    Does the page not have a checkbox or radio button that is unchecked?

    Finds by label or id.
  """
  def has_no_unchecked_field? text do
    retry fn ->
      element = find(:checkbox_or_radio, text)
      case is_element?(element) do
        true -> WebDriver.Element.selected? element
        false -> true
      end
    end
  end

  @doc """
    Does the page have a select with the given id, name or label.
  """
  def has_select? text do
    retry fn -> is_element? find(:select, text) end
  end

  @doc """
    Does the page not have a select with the given id, name or label.
  """
  def has_no_select? text do
    retry fn -> is_element? find(:select, text) end
  end

  @doc """
    Does the page have a table with the given caption or id?
  """
  def has_table? text do
    retry fn -> is_element? find(:table, text) end
  end

  @doc """
    Does the page not have a table with the given caption or id?
  """
  def has_no_table? text do
    retry fn -> is_not_element? find(:table, text) end
  end

  @doc """
    Does the page have an element matching the selector, using
    the strategy specified by the 'using' parameter.

   Using may be one of:

      * :class - Search for an element with the given class attribute.
      * :class_name - alias for :class
      * :css - Search for an element using a CSS selector.
      * :id - Find an element with the given id attribute.
      * :name - Find an element with the given name attribute.
      * :link - Find an link element containing the given text.
      * :partial_link - Find a link element containing a superset of the given text.
      * :tag - Find a HTML tag of the given type.
      * :xpath - Use [XPath](http://www.w3.org/TR/xpath/) to search for an element.

    Options include:

      * :count - Specify exactly the number of occurrences on the page of the selector
      that must be found for this to be true.

  """
  def has_selector? using, selector, options \\ [count: nil] do
    count = Keyword.get(options, :count)
    if count != nil do
      retry fn -> Enum.count(WebDriver.Session.elements(TucoTuco.current_session, using, selector)) == count end
    else
      retry fn -> is_element? WebDriver.Session.element(TucoTuco.current_session, using, selector) end
    end
  end

  @doc """
    The page has no elements matching the selector using the specified strategy.
  """
  def has_no_selector? using, selector do
    retry fn -> is_not_element? WebDriver.Session.element(TucoTuco.current_session, using, selector) end
  end

  @doc """
    Does the page contain the text specified?
  """
  def has_text? text do
    retry fn -> is_element? find(:xpath, "//*[contains(.,'#{text}')]") end
  end

  @doc """
    Does the page not contain the text specified?
  """
  def has_no_text? text do
    retry fn -> is_not_element? find(:xpath, "//*[contains(.,'#{text}')]") end
  end

  def is_element? %WebDriver.Element{id: _, session: _} do
    true
  end

  def is_element? _ do
    false
  end

  def is_not_element? element do
    !is_element? element
  end
end
