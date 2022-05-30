#!/usr/bin/env node

// 模拟方式接单、上传、查看详情(账密)，已弃用

const puppeteer = require('puppeteer-core')
const fire = require('js-fire')

const order = async (search = '') => {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9223',
  })
  const iPhone = puppeteer.devices['iPhone 6']
  const page = await browser.newPage()
  await page.emulate(iPhone)
  await page.goto('https://m.dailiantong.com/#/pages/notice/notice')
  await page.waitForSelector('.nav-left-text')
  await page.click('.nav-left-text')
  await page.waitForSelector('.uni-indexed-list__item')
  await page.click('.uni-indexed-list__item')
  await page.waitForSelector('.flex-item')
  await page.click('.flex-item')
  await page.waitForSelector('[data-text="全部"]')
  await page.click('[data-text="全部"]')
  await page.waitForSelector('.nav-right')
  await page.click('.nav-right')

  await page.waitForSelector('.uni-searchbar__box')
  await page.click('.uni-searchbar__box')
  await page.keyboard.type(search)
  await page.waitForSelector('[value="' + search + '"]')
  // await page.waitForSelector('.uni-searchbar__cancel')
  // await page.click('.uni-searchbar__cancel')
  await page.keyboard.press('Enter')

  await page.waitForSelector('.uni-list')
  await page.waitForSelector('.upwarp-nodata')
  const size = await page.$eval('.uni-list', (x) => x.childElementCount)
  console.log(size)
  if (size !== 1) {
    return browser.disconnect()
  }
  await page.click('.uni-list')
  await page.waitForSelector('.title')
  const title = await page.$eval('.title', (x) => x.textContent)
  const price = await page.$eval('.money', (x) => x.textContent)
  console.log(title)
  console.log(price)
  await page.waitForSelector('.uni-tab__cart-button-right')
  await page.click('.uni-tab__cart-button-right')
  await page.waitForSelector('.keyboar:nth-child(5)')
  await new Promise((r) => setTimeout(r, 500))
  await page.click('.keyboar:nth-child(1)')
  await page.click('.keyboar:nth-child(1)')
  await page.click('.keyboar:nth-child(1)')
  await page.click('.keyboar:nth-child(1)')
  await page.click('.keyboar:nth-child(1)')

  // console.log(price)
  // await page.waitForSelector('input')

  // await page.screenshot({ path: 'example.png' })
  // await new Promise((r) => setTimeout(r, 20000))

  // await browser.close()
  browser.disconnect()
}

const detail = async (search = '') => {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9223',
  })
  const iPhone = puppeteer.devices['iPhone 6']
  const page = await browser.newPage()
  await page.emulate(iPhone)
  await page.goto(
    'https://m.dailiantong.com/#/pages/order/order?detailData=%257B%2522publish%2522%253A0%257D'
  )

  await page.waitForSelector('.uni-nav-bar-right')
  await page.click('.uni-nav-bar-right')
  // await page.waitForSelector('.uni-searchbar__box')
  await new Promise((r) => setTimeout(r, 1000))
  // await page.click('.uni-searchbar__box')
  await page.keyboard.type(search)

  await new Promise((r) => setTimeout(r, 1000))

  // await page.waitForSelector('[value="' + search + '"]')
  // await page.waitForSelector('.uni-searchbar__cancel')
  // await page.click('.uni-searchbar__cancel')
  // await page.waitForSelector('.uni-searchbar__box')
  // await page.click('.uni-searchbar__box')
  await page.keyboard.press('Enter')

  // await new Promise((r) => setTimeout(r, 1000))

  // await page.waitForSelector('.uni-list-cell')
  // await page.click('.uni-list-cell')

  await page.waitForFunction(
    () => document.querySelectorAll('.uni-list .uni-list-cell').length == 1
  )
  // await page.waitForSelector('.uni-list-cell')
  //

  await new Promise((r) => setTimeout(r, 500))
  await page.click('.uni-list-cell')

  // 校验
  await page.waitForSelector('.orderInformationList span')
  const info2 = await page.$$eval('.orderInformationList span', (x) =>
    x.map((x) => x.textContent).join(' ')
  )
  if (!info2.includes(search)) {
    console.log('校验失败', info2, search)
    return
  }

  // exit()

  // const size = await page.$eval('.uni-list', (x) => x.childElementCount)
  // console.log(size)
  // if (size !== 1) {
  //   return browser.disconnect()
  // }

  await page.waitForSelector('.subtitle')
  await page.click('.subtitle')
  await page.waitForSelector('.uni-tip-button')
  await page.click('.uni-tip-button')

  // uni-nav-bar-right

  await page.waitForFunction(
    () =>
      !document.querySelector('.informationList span').textContent.endsWith('*')
  )
  const info = await page.$$eval('.informationList span', (x) =>
    x.map((x) => x.textContent).join(' ')
  )
  // const info2 = await page.$$eval('.orderInformationList span', (x) =>
  //   x.map((x) => x.textContent).join(' ')
  // )
  // const username = await page.$eval(
  //   '.informationList span',
  //   (x) => x.textContent
  // )
  // const password = await page.$eval(
  //   '.informationList:nth-child(2) span',
  //   (x) => x.textContent
  // )
  // const phone = await page.$eval(
  //   '.informationList:nth-child(3) span',
  //   (x) => x.textContent
  // )
  // const name = await page.$eval(
  //   '.informationList:nth-child(4) span',
  //   (x) => x.textContent
  // )
  // const name = await page.$eval(
  //   '.informationList:nth-child(4) span',
  //   (x) => x.textContent
  // )
  const title = await page.$eval('.title', (x) => x.textContent)
  const area = await page.$eval('.area', (x) => x.textContent)
  console.log(info, info2, title, area.replace('明日方舟', ''))

  browser.disconnect()
}

const upload = async (search = '', path = '') => {
  const browser = await puppeteer.connect({
    browserURL: 'http://localhost:9223',
  })
  const iPhone = puppeteer.devices['iPhone 6']
  const page = await browser.newPage()
  await page.emulate(iPhone)
  await page.goto(
    'https://m.dailiantong.com/#/pages/order/order?detailData=%257B%2522publish%2522%253A0%257D'
  )

  await page.waitForSelector('.uni-nav-bar-right')
  await page.click('.uni-nav-bar-right')
  await page.waitForSelector('.uni-searchbar__box')
  await page.click('.uni-searchbar__box')

  await new Promise((r) => setTimeout(r, 1000))
  await page.keyboard.type(search)
  // await page.waitForSelector('[value="' + search + '"]')
  // await page.waitForSelector('.uni-searchbar__cancel')
  // await page.click('.uni-searchbar__cancel')
  // await page.click('.uni-searchbar__box')
  await new Promise((r) => setTimeout(r, 1000))
  await page.keyboard.press('Enter')

  // await new Promise((r) => setTimeout(r, 500))
  //
  await page.waitForFunction(
    () => document.querySelectorAll('.uni-list .uni-list-cell').length == 1
  )

  await new Promise((r) => setTimeout(r, 500))

  await page.waitForSelector('.uni-list-cell')
  await page.click('.uni-list-cell')

  // 校验
  await page.waitForSelector('.orderInformationList span')
  const info2 = await page.$$eval('.orderInformationList span', (x) =>
    x.map((x) => x.textContent).join(' ')
  )
  if (!info2.includes(search)) {
    console.log('校验失败', info2, search)
    return
  }

  await page.waitForSelector('.uni-tab__right')
  await page.click('.uni-tab__right')
  await page.waitForSelector('.sunui-uploader-inputbox')
  await page.click('.sunui-uploader-inputbox')
  // const fileChooser = await page.waitForFileChooser()
  const [fileChooser] = await Promise.all([
    page.waitForFileChooser(),
    page.click('.sunui-uploader-inputbox'),
    // page.click('#upload-file-button'), // some button that triggers file selection
  ])
  await fileChooser.accept([path])
  // TODO
  console.log(155)

  // await page.click('.submitBtn')
  await new Promise((r) => setTimeout(r, 1000))
  // TODO，支持两个图
  await page.waitForSelector('.submitBtn')
  console.log(156)
  // await page.click('.submitBtn')

  browser.disconnect()
}

// .uni-tab__cart-sub-right

fire({ order, detail, upload })
