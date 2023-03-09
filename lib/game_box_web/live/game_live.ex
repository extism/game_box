defmodule GameBoxWeb.GameLive do
  use GameBoxWeb, :live_view

  def render(assigns) do
    ~H"""
    <div style="width: 100%; background-image: linear-gradient(to bottom, var(--tw-gradient-stops)); --tw-gradient-from: #9333ea; --tw-gradient-stops: var(--tw-gradient-from), var(--tw-gradient-to); --tw-gradient-to: #6b21a8; padding-left: 24px; padding-right: 24px; padding-top: 12px; padding-bottom: 12px; font-size: 30px">
      Guess the Song: <b>Imagine Dragons</b>
    </div>
    <div style="display: flex; height: 100%; min-height: 42rem; flex-direction: column; align-items: center; justify-content: flex-start; border-width: 4px; border-color: #581c87; background-image: url('http://amymurphy.tech/images/idbg.jpg'); padding: 24px; padding-top: 40px">
      <div style="width: 91%; background-color: rgb(88 28 135 / 0.5); padding: 40px; font-size: 22px; color: #fff">
        "i was broken from a young age taking my sulking to the masses"
      </div>
      <div style="display: grid; grid-template-columns: repeat(2, minmax(0, 1fr));  width: 100%; align-items: center; justify-content: center; column-gap: 24px; row-gap: 24px; padding-left: 48px; padding-right: 48px; padding-top: 24px; padding-bottom: 24px">
        <div
          class="hover-bg-purple-600-50"
          style="cursor: pointer; background-color: rgb(88 28 135 / 0.5); padding: 24px;font-size: 18px "
        >
          Radioactive
        </div>
        <div
          class="hover-bg-purple-600-50"
          style="cursor: pointer; border-width: 1px; border-color: #86efac; background-color: rgb(88 28 135 / 0.5); padding: 24px"
        >
          <div style="display: flex; align-items: center; color: #86efac; font-size: 18px">
            <div style="font-size: 18px;">Believer</div>
            <div style="margin-left: 12px; font-size: 14px; color: #d8b4fe">| Jackson | Amy |</div>
          </div>
        </div>
        <div
          class="hover-bg-purple-600-50"
          style="cursor: pointer; background-color: rgb(88 28 135 / 0.5); padding: 24px"
        >
          <div style="display: flex; align-items: center">
            <div style="font-size: 18px">Bones</div>
            <div style="margin-left: 12px; font-size: 14px; color: #d8b4fe ">Dan</div>
          </div>
        </div>
        <div
          class="hover-bg-purple-600-50"
          style="cursor: pointer; background-color: rgb(88 28 135 / 0.5); padding: 24px"
        >
          <span style="font-size: 18px">Monday</span>
        </div>
      </div>
      <div style="margin-top: 40px; display: flex; width: 100%; column-gap: 12px; text-align: left">
        <div style="width: 50%; background-color: rgb(255 255 255 / 0.1); padding: 12px">
          <p style="margin-bottom: 8px">
            ANSWER STATUS
          </p>
          <ul style="font-size: 22px; color: #d8b4fe">
            <li>
              Amy
              <svg
                version="1.1"
                id="L9"
                xmlns="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                x="0px"
                y="0px"
                viewBox="0 0 100 100"
                enable-background="new 0 0 0 0"
                xml:space="preserve"
                width="20"
                height="20"
                style="display: inline"
              >
                <path
                  fill="#d8b4fe"
                  d="M73,50c0-12.7-10.3-23-23-23S27,37.3,27,50 M30.9,50c0-10.5,8.5-19.1,19.1-19.1S69.1,39.5,69.1,50"
                >
                  <animateTransform
                    attributeName="transform"
                    attributeType="XML"
                    type="rotate"
                    dur="1s"
                    from="0 50 50"
                    to="360 50 50"
                    repeatCount="indefinite"
                  />
                </path>
              </svg>
            </li>
            <li style="color: #fff">
              <span>Jackson</span>
            </li>
            <li>
              Dan
              <svg
                version="1.1"
                id="L9"
                xmlns="http://www.w3.org/2000/svg"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                x="0px"
                y="0px"
                viewBox="0 0 100 100"
                enable-background="new 0 0 0 0"
                xml:space="preserve"
                width="20"
                height="20"
                style="display: inline"
              >
                <path
                  fill="#d8b4fe"
                  d="M73,50c0-12.7-10.3-23-23-23S27,37.3,27,50 M30.9,50c0-10.5,8.5-19.1,19.1-19.1S69.1,39.5,69.1,50"
                >
                  <animateTransform
                    attributeName="transform"
                    attributeType="XML"
                    type="rotate"
                    dur="1s"
                    from="0 50 50"
                    to="360 50 50"
                    repeatCount="indefinite"
                  />
                </path>
              </svg>
            </li>
          </ul>
        </div>
        <div style="width: 50%; background-color: rgb(255 255 255 / 0.1); padding: 12px">
          <p style="margin-bottom: 8px">
            GAME INFO
          </p>
          <p>
            <b>Round:</b> <span style="color: #d8b4fe">7 of 10</span>
          </p>
          <hr style="margin-top: 12px; margin-bottom: 12px" />
          <p>
            <b>Score:</b>
          </p>
          <div style="display: grid; grid-template-columns: repeat(3, minmax(0, 1fr))">
            <div>Amy: <span style="color: #d8b4fe">5</span></div>
            <div>Jackson: <span style="color: #d8b4fe">7</span></div>
            <div>Dan: <span style="color: #d8b4fe">4</span></div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
